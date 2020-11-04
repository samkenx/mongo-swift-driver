import Foundation
import MongoSwiftSync
import TestsCommon

struct UnifiedOperation: Decodable {
    /// Represents an object on which to perform an operation.
    enum Object: RawRepresentable, Decodable {
        /// Used for special test operations.
        case testRunner
        /// An entity name e.g. "client0".
        case entity(String)

        public var rawValue: String {
            switch self {
            case .testRunner:
                return "testRunner"
            case let .entity(s):
                return s
            }
        }

        public init(rawValue: String) {
            switch rawValue {
            case "testRunner":
                self = .testRunner
            default:
                self = .entity(rawValue)
            }
        }
    }

    /// Object on which to perform the operation.
    let object: Object

    let operation: UnifiedOperationProtocol

    /// Represents the expected result of an operation.
    enum Result {
        /// One or more assertions for an error expected to be raised by the operation.
        case error(ExpectedError)
        /// - result: A value corresponding to the expected result of the operation.
        /// - saveAsEntity: If specified, the actual result returned by the operation (if any) will be saved with this
        ///       name in the Entity Map. The test runner MUST raise an error if the name is already in use or if the
        ///       result does not comply with Supported Entity Types.
        case result(result: BSON?, saveAsEntity: String?)
    }

    /// Expected result of the operation.
    let result: Result?

    private enum CodingKeys: String, CodingKey {
        case name, object, arguments, expectError, expectResult, saveResultAsEntity
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(String.self, forKey: .name)
        switch name {
        case "createChangeStream":
            self.operation = try container.decode(CreateChangeStreamOperation.self, forKey: .arguments)
        case "insertOne":
            self.operation = try container.decode(InsertOneOperation.self, forKey: .arguments)
        case "insertMany":
            self.operation = try container.decode(InsertManyOperation.self, forKey: .arguments)
        case "bulkWrite":
            self.operation = try container.decode(BulkWriteOperation.self, forKey: .arguments)
        case "replaceOne":
            self.operation = try container.decode(ReplaceOneOperation.self, forKey: .arguments)
        case "find":
            self.operation = try container.decode(FindOperation.self, forKey: .arguments)
        case "aggregate":
            self.operation = try container.decode(AggregateOperation.self, forKey: .arguments)
        case "findOneAndUpdate":
            self.operation = try container.decode(FindOneAndUpdateOperation.self, forKey: .arguments)
        case "findOneAndReplace":
            self.operation = try container.decode(FindOneAndReplaceOperation.self, forKey: .arguments)
        case "iterateUntilDocumentOrError":
             self.operation = IterateUntilDocumentOrErrorOperation()
        case "failPoint":
            self.operation = try container.decode(FailPointOperation.self, forKey: .arguments)
        case "targetedFailPoint":
            self.operation = try container.decode(TargetedFailPointOperation.self, forKey: .arguments)
        case "assertSessionNotDirty":
            self.operation = try container.decode(AssertSessionNotDirtyOperation.self, forKey: .arguments)
        case "assertSessionDirty":
            self.operation = try container.decode(AssertSessionDirtyOperation.self, forKey: .arguments)
        case "endSession":
            self.operation = EndSessionOperation()
        case "assertSameLsidOnLastTwoCommands":
            self.operation = try container.decode(AssertSameLsidOnLastTwoCommandsOperation.self, forKey: .arguments)
        case "assertDifferentLsidOnLastTwoCommands":
            self.operation = try container.decode(AssertDifferentLsidOnLastTwoCommandsOperation.self, forKey: .arguments)
        case "assertSessionPinned":
            self.operation = try container.decode(AssertSessionPinnedOperation.self, forKey: .arguments)
        case "assertSessionUnpinned":
            self.operation = try container.decode(AssertSessionUnpinnedOperation.self, forKey: .arguments)
        case "startTransaction":
            self.operation = try container.decodeIfPresent(StartTransactionOperation.self, forKey: .arguments) ?? StartTransactionOperation()
        case "commitTransaction":
            self.operation = try container.decodeIfPresent(CommitTransactionOperation.self, forKey: .arguments) ?? CommitTransactionOperation()
        case "abortTransaction":
            self.operation = try container.decodeIfPresent(AbortTransactionOperation.self, forKey: .arguments) ?? AbortTransactionOperation()
        case "assertSessionTransactionState":
            self.operation = try container.decode(AssertSessionTransactionStateOperation.self, forKey: .arguments)
        case "dropCollection":
            self.operation = try container.decode(DropCollectionOperation.self, forKey: .arguments)
        case "createCollection":
            self.operation = try container.decode(CreateCollectionOperation.self, forKey: .arguments)
        case "assertCollectionNotExists":
            self.operation = try container.decode(AssertCollectionNotExistsOperation.self, forKey: .arguments)
        case "assertCollectionExists":
            self.operation = try container.decode(AssertCollectionExistsOperation.self, forKey: .arguments)
        case "listDatabases":
            self.operation = ListDatabasesOperation()
        case "createIndex":
            self.operation = try container.decode(CreateIndexOperation.self, forKey: .arguments)
        case "assertIndexNotExists":
            self.operation = try container.decode(AssertIndexNotExistsOperation.self, forKey: .arguments)
        case "assertIndexExists":
            self.operation = try container.decode(AssertIndexExistsOperation.self, forKey: .arguments)
        default:
            throw TestError(message: "Unrecognized operation type \(name)")
        }

        let rawArgs = try container.decodeIfPresent(BSONDocument.self, forKey: .arguments)?.keys ?? []
        for arg in rawArgs where !type(of: self.operation).knownArguments.contains(arg) {
            throw TestError(message: "Unrecognized argument \(arg) for operation type \(type(of: self.operation))")
        }

        self.object = try container.decode(Object.self, forKey: .object)
        if let expectError = try container.decodeIfPresent(ExpectedError.self, forKey: .expectError) {
            self.result = .error(expectError)
            return
        }

        let expectResult = try container.decodeIfPresent(BSON.self, forKey: .expectResult)
        let saveAsEntity = try container.decodeIfPresent(String.self, forKey: .saveResultAsEntity)

        guard expectResult != nil || saveAsEntity != nil else {
            self.result = nil
            return
        }

        self.result = .result(result: expectResult, saveAsEntity: saveAsEntity)
    }
}

protocol UnifiedOperationProtocol: Decodable {
    static var knownArguments: Set<String> { get }
}

extension UnifiedOperationProtocol {
    static var knownArguments: Set<String> { [] }
}

/// One or more assertions for an error/exception, which is expected to be raised by an executed operation. At least
/// one key is required in this object.
struct ExpectedError: Decodable {
    /// If true, the test runner MUST assert that an error was raised.
    let isError: Bool?

    /// If true, the test runner MUST assert that the error originates from the client (i.e. it is not derived from a
    /// server response). If false, the test runner MUST assert that the error does not originate from the client.
    let isClientError: Bool?

    ///  A substring of the expected error message (e.g. "errmsg" field in a server error document). The test runner
    /// MUST assert that the error message contains this string using a case-insensitive match.
    let errorContains: String?

    /// The expected "code" field in the server-generated error response. The test runner MUST assert that the error
    /// includes a server-generated response whose "code" field equals this value. 
    let errorCode: Int?

    /// The expected "codeName" field in the server-generated error response. The test runner MUST assert that the
    /// error includes a server-generated response whose "codeName" field equals this value using a case-insensitive
    /// comparison.
    let errorCodeName: String?

    /// A list of error label strings that the error is expected to have. The test runner MUST assert that the error
    /// contains all of the specified labels (e.g. using the hasErrorLabel method).
    let errorLabelsContain: [String]?

    /// A list of error label strings that the error is expected not to have. The test runner MUST assert that the
    /// error does not contain any of the specified labels (e.g. using the hasErrorLabel method).
    let errorLabelsOmit: [String]?

    /// This field is only used in cases where the error includes a result (e.g. bulkWrite).
    let expectResult: BSON?
}
