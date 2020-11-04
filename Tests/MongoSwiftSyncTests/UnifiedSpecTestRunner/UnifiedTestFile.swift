import MongoSwiftSync
import TestsCommon

struct SchemaVersion: RawRepresentable, Comparable, Decodable {
    let major: Int
    
    let minor: Int

    let patch: Int

    public init?(rawValue: String) {
        var components = rawValue.split(separator: ".")
        // invalid number of components.
        guard (1...3).contains(components.count) else {
            return nil
        }

        guard let major = Int(components.removeFirst()) else {
            return nil
        }
        self.major = major

        guard !components.isEmpty else {
            self.minor = 0
            self.patch = 0
            return
        }

        guard let minor = Int(components.removeFirst()) else {
            return nil
        }
        self.minor = minor

        guard !components.isEmpty else {
            self.patch = 0
            return
        }

        guard let patch = Int(components.removeFirst()) else {
            return nil
        }
        self.patch = patch
    }

    public var rawValue: String {
        "\(major).\(minor).\(patch)"
    }

    public static func < (lhs: SchemaVersion, rhs: SchemaVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        } else if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        } else {
            return lhs.patch < rhs.patch
        }
    }
}

struct UnifiedTestRunner {
    let internalClient: MongoClient
    let serverVersion: ServerVersion
    let topologyType: TestTopologyConfiguration

    static let MIN_SCHEMA_VERSION = SchemaVersion(rawValue: "1.0.0")!
    static let MAX_SCHEMA_VERSION = SchemaVersion(rawValue: "1.0.0")!

    init() throws {
        let connStr = MongoSwiftTestCase.getConnectionString(singleMongos: false).toString()
        self.internalClient = try MongoClient.makeTestClient(connStr)
        self.serverVersion = try self.internalClient.serverVersion()
        let reply = try self.internalClient.db("admin").runCommand(["isMaster": 1])
        self.topologyType = try TestTopologyConfiguration(isMasterReply: reply)

        // The test runner SHOULD terminate any open transactions using the internal MongoClient before executing any
        // tests. Using the internal MongoClient, execute the killAllSessions command on either the primary or, if
        // connected to a sharded cluster, all mongos servers.
        switch self.topologyType {
        case .single:
            return
        case .replicaSet:
            let admin = self.internalClient.db("admin")
            for address in MongoSwiftTestCase.getHosts() {
                let isMaster = try admin.runCommand(["isMaster": 1], on: address)["ismaster"]!.boolValue!
                if isMaster {
                    _ = try admin.runCommand(["killAllSessions": []], on: address)
                    return
                }
            }
        case .sharded:
            for address in MongoSwiftTestCase.getHosts() {
                _ = try self.internalClient.db("admin").runCommand(["killAllSessions": []], on: address)
            }
        }
    }

    func getUnmetRequirement(_ requirement: TestRequirement) -> UnmetRequirement? {
        requirement.getUnmetRequirement(givenCurrent: self.serverVersion, self.topologyType)
    }

    func runFiles(_ files: [UnifiedTestFile]) throws {
        for file in files {
            // Upon loading a file, the test runner MUST read the schemaVersion field and determine if the test file
            // can be processed further.
            guard file.schemaVersion >= Self.MIN_SCHEMA_VERSION && file.schemaVersion <= Self.MAX_SCHEMA_VERSION else {
                throw TestError(
                    message: "Test file \"\(file.description)\" has unsupported schema version \(file.schemaVersion)"
                )
            }

            // If runOnRequirements is specified, the test runner MUST skip the test file unless one or more
            //  runOnRequirement objects are satisfied.
            if let requirements = file.runOnRequirements {
                guard requirements.contains(where: { self.getUnmetRequirement($0) == nil }) else {
                    fileLevelLog("Skipping tests from file \"\(file.description)\", deployment requirements not met.")
                    continue
                }
            }

            for test in file.tests {
                // If test.skipReason is specified, the test runner MUST skip this test and MAY use the string value to
                // log a message.
                if let skipReason = test.skipReason {
                    fileLevelLog(
                        "Skipping test \"\(test.description)\" from file \"\(file.description)\": \(skipReason)."
                    )
                    continue
                }

                // If test.runOnRequirements is specified, the test runner MUST skip the test unless one or more
                // runOnRequirement objects are satisfied.
                if let requirements = test.runOnRequirements {
                    guard requirements.contains(where: { self.getUnmetRequirement($0)  == nil }) else {
                        fileLevelLog(
                            "Skipping test \"\(test.description)\" from file \"\(file.description)\", " + 
                            "deployment requirements not met."
                        )
                        continue
                    }
                }

                // If initialData is specified, for each collectionData therein the test runner MUST drop the
                // collection and insert the specified documents (if any) using a "majority" write concern. If no
                // documents are specified, the test runner MUST create the collection with a "majority" write concern.
                // The test runner MUST use the internal MongoClient for these operations.
                if let initialData = file.initialData {
                    for collData in initialData {
                        let db = internalClient.db(collData.databaseName)
                        let coll = db.collection(collData.databaseName)
                        try coll.drop(options: DropCollectionOptions(writeConcern: .majority))

                        guard !collData.documents.isEmpty else {
                            try db.createCollection(collData.collectionName, options: CreateCollectionOptions(writeConcern: .majority))
                            continue
                        }

                        try coll.insertMany(collData.documents, options: insertManyOptions(writeConcern: .majority))
                    }
                }

                var entityMap = [String: ]
            }
        }
    }
}

/// Structure representing a test file in the unified test format.
struct UnifiedTestFile: Decodable {
    /// The name of the test file.
    let description: String

    /// Version of this specification with which the test file complies.
    let schemaVersion: SchemaVersion

    /// Optional array of one or more version/topology test requirements.  If no requirements are met, the test runner
    /// MUST skip this test file.
    let runOnRequirements: [TestRequirement]?

    /// Optional array of one or more entity objects (e.g. client, collection, session objects) that SHALL be created
    /// before each test case is executed.
    let createEntities: [EntityDescription]?

    /// Optional array of one or more collectionData objects. Data that will exist in collections before each test case
    /// is executed.
    let initialData: [CollectionData]?

    /// Required array of one or more test objects. List of test cases to be executed independently of each other.
    let tests: [UnifiedTest]
}

/// List of documents corresponding to the contents of a collection.
struct CollectionData: Decodable {
    /// The name of a collection.
    let collectionName: String

    /// The name of a database.
    let databaseName: String

    /// List of documents corresponding to the contents of the collection. May be empty.
    let documents: [BSONDocument]
}

/// Represents a single test in a test file.
struct UnifiedTest: Decodable {
    /// The name of the test.
    let description: String

    /// Optional array of one or more runOnRequirement objects. List of server version and/or topology requirements for
    /// which this test can be run. If specified, these requirements are evaluated independently and in addition to any
    /// top-level runOnRequirements. If no requirements in this array are met, the test runner MUST skip this test.
    let runOnRequirements: [TestRequirement]?

    /// Optional string. If set, the test will be skipped.
    let skipReason: String?

    /// Array of one or more operation objects. List of operations to be executed for the test case.
    let operations: [UnifiedOperation]

    /// Optional array of one or more expectedEventsForClient objects. For one or more clients, a list of events that are
    /// expected to be observed in a particular order.
    let expectEvents: [ExpectedEventsForClient]?

    /// Data that is expected to exist in collections after the test case is executed.
    let outcome: [CollectionData]?
}
