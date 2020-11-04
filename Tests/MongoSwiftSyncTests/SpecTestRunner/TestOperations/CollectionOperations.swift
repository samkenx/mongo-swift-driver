import Foundation
import MongoSwiftSync
import TestsCommon

// File containing the TestOperations executed on a collections.

struct Aggregate: TestOperation {
    let session: String?
    let pipeline: [BSONDocument]
    let options: AggregateOptions

    private enum CodingKeys: String, CodingKey { case session, pipeline }

    init(from decoder: Decoder) throws {
        self.options = try AggregateOptions(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.pipeline = try container.decode([BSONDocument].self, forKey: .pipeline)
    }

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        let cursor =
            try collection.aggregate(self.pipeline, options: self.options, session: sessions[self.session ?? ""])
        return try TestOperationResult(from: cursor)
    }
}

struct CountDocuments: TestOperation {
    let session: String?
    let filter: BSONDocument
    let options: CountDocumentsOptions

    private enum CodingKeys: String, CodingKey { case session, filter }

    init(from decoder: Decoder) throws {
        self.options = try CountDocumentsOptions(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.filter = try container.decode(BSONDocument.self, forKey: .filter)
    }

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        .int(try collection.countDocuments(self.filter, options: self.options, session: sessions[self.session ?? ""]))
    }
}

struct Distinct: TestOperation {
    let session: String?
    let fieldName: String
    let filter: BSONDocument?
    let options: DistinctOptions

    private enum CodingKeys: String, CodingKey { case session, fieldName, filter }

    init(from decoder: Decoder) throws {
        self.options = try DistinctOptions(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.fieldName = try container.decode(String.self, forKey: .fieldName)
        self.filter = try container.decodeIfPresent(BSONDocument.self, forKey: .filter)
    }

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        let result = try collection.distinct(
            fieldName: self.fieldName,
            filter: self.filter ?? [:],
            options: self.options,
            session: sessions[self.session ?? ""]
        )
        return .array(result)
    }
}

struct Find: TestOperation {
    let session: String?
    let filter: BSONDocument
    let options: FindOptions

    private enum CodingKeys: String, CodingKey { case session, filter }

    init(from decoder: Decoder) throws {
        self.options = try FindOptions(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.filter = (try container.decodeIfPresent(BSONDocument.self, forKey: .filter)) ?? BSONDocument()
    }

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        try TestOperationResult(
            from: try collection.find(self.filter, options: self.options, session: sessions[self.session ?? ""])
        )
    }
}

struct FindOne: TestOperation {
    let session: String?
    let filter: BSONDocument
    let options: FindOneOptions

    private enum CodingKeys: String, CodingKey { case session, filter }

    init(from decoder: Decoder) throws {
        self.options = try FindOneOptions(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.filter = try container.decode(BSONDocument.self, forKey: .filter)
    }

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        let doc = try collection.findOne(self.filter, options: self.options, session: sessions[self.session ?? ""])
        return TestOperationResult(from: doc)
    }
}

struct UpdateOne: TestOperation {
    let session: String?
    let filter: BSONDocument
    let update: BSONDocument
    let options: UpdateOptions

    private enum CodingKeys: String, CodingKey { case session, filter, update }

    init(from decoder: Decoder) throws {
        self.options = try UpdateOptions(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.filter = try container.decode(BSONDocument.self, forKey: .filter)
        self.update = try container.decode(BSONDocument.self, forKey: .update)
    }

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        let result = try collection.updateOne(
            filter: self.filter,
            update: self.update,
            options: self.options,
            session: sessions[self.session ?? ""]
        )
        return TestOperationResult(from: result)
    }
}

struct UpdateMany: TestOperation {
    let session: String?
    let filter: BSONDocument
    let update: BSONDocument
    let options: UpdateOptions

    private enum CodingKeys: String, CodingKey { case session, filter, update }

    init(from decoder: Decoder) throws {
        self.options = try UpdateOptions(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.filter = try container.decode(BSONDocument.self, forKey: .filter)
        self.update = try container.decode(BSONDocument.self, forKey: .update)
    }

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        let result = try collection.updateMany(
            filter: self.filter,
            update: self.update,
            options: self.options,
            session: sessions[self.session ?? ""]
        )
        return TestOperationResult(from: result)
    }
}

struct DeleteMany: TestOperation {
    let session: String?
    let filter: BSONDocument
    let options: DeleteOptions

    private enum CodingKeys: String, CodingKey { case session, filter }

    init(from decoder: Decoder) throws {
        self.options = try DeleteOptions(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.filter = try container.decode(BSONDocument.self, forKey: .filter)
    }

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        let result =
            try collection.deleteMany(self.filter, options: self.options, session: sessions[self.session ?? ""])
        return TestOperationResult(from: result)
    }
}

struct DeleteOne: TestOperation {
    let session: String?
    let filter: BSONDocument
    let options: DeleteOptions

    private enum CodingKeys: String, CodingKey { case session, filter }

    init(from decoder: Decoder) throws {
        self.options = try DeleteOptions(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.filter = try container.decode(BSONDocument.self, forKey: .filter)
    }

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        let result = try collection.deleteOne(self.filter, options: self.options, session: sessions[self.session ?? ""])
        return TestOperationResult(from: result)
    }
}

struct InsertOne: TestOperation {
    let session: String?
    let document: BSONDocument

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        let result = try collection.insertOne(self.document, session: sessions[self.session ?? ""])
        return TestOperationResult(from: result)
    }
}

struct InsertMany: TestOperation {
    let session: String?
    let documents: [BSONDocument]
    let options: InsertManyOptions?

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        let result = try collection.insertMany(
            self.documents,
            options: self.options,
            session: sessions[self.session ?? ""]
        )
        return TestOperationResult(from: result)
    }
}

/// Extension of `WriteModel` adding `Decodable` conformance.
extension WriteModel: Decodable {
    private enum CodingKeys: CodingKey {
        case name, arguments, insertOne, deleteOne, deleteMany, replaceOne, updateOne, updateMany
    }

    private enum InsertOneKeys: String, CodingKey, CaseIterable {
        case document
    }

    private enum DeleteKeys: String, CodingKey, CaseIterable {
        case filter
    }

    private enum ReplaceOneKeys: String, CodingKey, CaseIterable {
        case filter, replacement, upsert, collation
    }

    private enum UpdateKeys: String, CodingKey, CaseIterable {
        case filter, update, arrayFilters, collation, upsert
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // old way of structuring bulk writes in tests
        if let name = try container.decodeIfPresent(String.self, forKey: .name) {
            switch name {
            case "insertOne":
                let args = try container.nestedContainer(keyedBy: InsertOneKeys.self, forKey: .arguments)
                let doc = try args.decode(CollectionType.self, forKey: .document)
                self = .insertOne(doc)
            case "deleteOne", "deleteMany":
                let options = try container.decode(DeleteModelOptions.self, forKey: .arguments)
                let args = try container.nestedContainer(keyedBy: DeleteKeys.self, forKey: .arguments)
                let filter = try args.decode(BSONDocument.self, forKey: .filter)
                self = name == "deleteOne" ? .deleteOne(filter, options: options) : .deleteMany(filter, options: options)
            case "replaceOne":
                let options = try container.decode(ReplaceOneModelOptions.self, forKey: .arguments)
                let args = try container.nestedContainer(keyedBy: ReplaceOneKeys.self, forKey: .arguments)
                let filter = try args.decode(BSONDocument.self, forKey: .filter)
                let replacement = try args.decode(CollectionType.self, forKey: .replacement)
                self = .replaceOne(filter: filter, replacement: replacement, options: options)
            case "updateOne", "updateMany":
                let options = try container.decode(UpdateModelOptions.self, forKey: .arguments)
                let args = try container.nestedContainer(keyedBy: UpdateKeys.self, forKey: .arguments)
                let filter = try args.decode(BSONDocument.self, forKey: .filter)
                let update = try args.decode(BSONDocument.self, forKey: .update)
                self = name == "updateOne" ?
                    .updateOne(filter: filter, update: update, options: options) :
                    .updateMany(filter: filter, update: update, options: options)
            default:
                throw DecodingError.typeMismatch(
                    WriteModel.self,
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Unknown write model: \(name)"
                    )
                )
            }
        // new unified way
        } else {
            let opName: String
            let rawArgs: [String]
            let knownArgs: Set<String>

            if let insertOne = try? container.nestedContainer(keyedBy: InsertOneKeys.self, forKey: .insertOne) {
                let doc = try insertOne.decode(CollectionType.self, forKey: .document)
                self = .insertOne(doc)

                opName = "insertOne"
                rawArgs = try container.decode(BSONDocument.self, forKey: .insertOne).keys
                knownArgs = Set(InsertOneKeys.allCases.map { $0.rawValue })

            } else if let deleteOne = try? container.nestedContainer(keyedBy: DeleteKeys.self, forKey: .deleteOne) {
                let filter = try deleteOne.decode(BSONDocument.self, forKey: .filter)
                let options = try container.decode(DeleteModelOptions.self, forKey: .deleteOne)

                self = .deleteOne(filter, options: options)

                opName = "deleteOne"
                rawArgs = try container.decode(BSONDocument.self, forKey: .deleteOne).keys
                knownArgs = Set(
                    DeleteKeys.allCases.map { $0.rawValue } +
                    Mirror(reflecting: options).children.map { $0.label! }
                )

            } else if let deleteMany = try? container.nestedContainer(keyedBy: DeleteKeys.self, forKey: .deleteMany) {
                let filter = try deleteMany.decode(BSONDocument.self, forKey: .filter)
                let options = try container.decode(DeleteModelOptions.self, forKey: .deleteMany)

                self = .deleteMany(filter, options: options)
                
                opName = "deleteMany"
                rawArgs = try container.decode(BSONDocument.self, forKey: .deleteMany).keys
                knownArgs = Set(
                    DeleteKeys.allCases.map { $0.rawValue } +
                    Mirror(reflecting: options).children.map { $0.label! }
                )

            } else if let replaceOne = try? container.nestedContainer(keyedBy: ReplaceOneKeys.self, forKey: .replaceOne) {
                let filter = try replaceOne.decode(BSONDocument.self, forKey: .filter)
                let replacement = try replaceOne.decode(CollectionType.self, forKey: .replacement)
                let options = try container.decode(ReplaceOneModelOptions.self, forKey: .replaceOne)

                self = .replaceOne(filter: filter, replacement: replacement, options: options)

                opName = "replaceOne"
                rawArgs = try container.decode(BSONDocument.self, forKey: .replaceOne).keys
                knownArgs = Set(
                    ReplaceOneKeys.allCases.map { $0.rawValue } +
                    Mirror(reflecting: options).children.map { $0.label! }
                )

            } else if let updateOne = try? container.nestedContainer(keyedBy: UpdateKeys.self, forKey: .updateOne) {
                let filter = try updateOne.decode(BSONDocument.self, forKey: .filter)
                let update = try updateOne.decode(BSONDocument.self, forKey: .update)
                let options = try container.decode(UpdateModelOptions.self, forKey: .updateOne)

                self = .updateOne(filter: filter, update: update, options: options)

                opName = "updateOne"
                rawArgs = try container.decode(BSONDocument.self, forKey: .updateOne).keys
                knownArgs = Set(
                    UpdateKeys.allCases.map { $0.rawValue } +
                    Mirror(reflecting: options).children.map { $0.label! }
                )
            } else {
                let updateMany = try container.nestedContainer(keyedBy: UpdateKeys.self, forKey: .updateMany)
                let filter = try updateMany.decode(BSONDocument.self, forKey: .filter)
                let update = try updateMany.decode(BSONDocument.self, forKey: .update)
                let options = try container.decode(UpdateModelOptions.self, forKey: .updateMany)

                self = .updateMany(filter: filter, update: update, options: options)

                opName = "updateMany"
                rawArgs = try container.decode(BSONDocument.self, forKey: .updateMany).keys
                knownArgs = Set(
                    UpdateKeys.allCases.map { $0.rawValue } +
                    Mirror(reflecting: options).children.map { $0.label! }
                )
            }

            for arg in rawArgs where !knownArgs.contains(arg) {
                throw TestError(message: "Unsupported argument for bulkWrite \(opName): \(arg)")
            }
        }
    }
}

struct BulkWrite: TestOperation {
    let session: String?
    let requests: [WriteModel<BSONDocument>]
    let options: BulkWriteOptions?

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        let result =
            try collection.bulkWrite(self.requests, options: self.options, session: sessions[self.session ?? ""])
        return TestOperationResult(from: result)
    }
}

struct FindOneAndUpdate: TestOperation {
    let session: String?
    let filter: BSONDocument
    let update: BSONDocument
    let options: FindOneAndUpdateOptions

    private enum CodingKeys: String, CodingKey { case session, filter, update }

    init(from decoder: Decoder) throws {
        self.options = try FindOneAndUpdateOptions(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.filter = try container.decode(BSONDocument.self, forKey: .filter)
        self.update = try container.decode(BSONDocument.self, forKey: .update)
    }

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        let doc = try collection.findOneAndUpdate(
            filter: self.filter,
            update: self.update,
            options: self.options,
            session: sessions[self.session ?? ""]
        )
        return TestOperationResult(from: doc)
    }
}

struct FindOneAndDelete: TestOperation {
    let session: String?
    let filter: BSONDocument
    let options: FindOneAndDeleteOptions

    private enum CodingKeys: String, CodingKey { case session, filter }

    init(from decoder: Decoder) throws {
        self.options = try FindOneAndDeleteOptions(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.filter = try container.decode(BSONDocument.self, forKey: .filter)
    }

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        let result = try collection.findOneAndDelete(
            self.filter,
            options: self.options,
            session: sessions[self.session ?? ""]
        )
        return TestOperationResult(from: result)
    }
}

struct FindOneAndReplace: TestOperation {
    let session: String?
    let filter: BSONDocument
    let replacement: BSONDocument
    let options: FindOneAndReplaceOptions

    private enum CodingKeys: String, CodingKey { case session, filter, replacement }

    init(from decoder: Decoder) throws {
        self.options = try FindOneAndReplaceOptions(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.filter = try container.decode(BSONDocument.self, forKey: .filter)
        self.replacement = try container.decode(BSONDocument.self, forKey: .replacement)
    }

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        let result = try collection.findOneAndReplace(
            filter: self.filter,
            replacement: self.replacement,
            options: self.options,
            session: sessions[self.session ?? ""]
        )
        return TestOperationResult(from: result)
    }
}

struct ReplaceOne: TestOperation {
    let session: String?
    let filter: BSONDocument
    let replacement: BSONDocument
    let options: ReplaceOptions

    private enum CodingKeys: String, CodingKey { case session, filter, replacement }

    init(from decoder: Decoder) throws {
        self.options = try ReplaceOptions(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.filter = try container.decode(BSONDocument.self, forKey: .filter)
        self.replacement = try container.decode(BSONDocument.self, forKey: .replacement)
    }

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        let result = try collection.replaceOne(
            filter: self.filter,
            replacement: self.replacement,
            options: self.options,
            session: sessions[self.session ?? ""]
        )
        return TestOperationResult(from: result)
    }
}

struct RenameCollection: TestOperation {
    let session: String?
    let to: String

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        let databaseName = collection.namespace.db
        let cmd: BSONDocument = [
            "renameCollection": .string(databaseName + "." + collection.name),
            "to": .string(databaseName + "." + self.to)
        ]
        let reply = try collection._client.db("admin").runCommand(cmd, session: sessions[self.session ?? ""])
        return TestOperationResult(from: reply)
    }
}

struct Drop: TestOperation {
    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions _: [String: ClientSession]
    ) throws -> TestOperationResult? {
        try collection.drop()
        return nil
    }
}

struct ListIndexes: TestOperation {
    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions _: [String: ClientSession]
    ) throws -> TestOperationResult? {
        try TestOperationResult(from: collection.listIndexes())
    }
}

struct ListIndexNames: TestOperation {
    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions _: [String: ClientSession]
    ) throws -> TestOperationResult? {
        try .array(collection.listIndexNames().map(BSON.string))
    }
}

struct EstimatedDocumentCount: TestOperation {
    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions _: [String: ClientSession]
    ) throws -> TestOperationResult? {
        try .int(collection.estimatedDocumentCount())
    }
}

struct CreateIndex: TestOperation {
    let session: String?
    let name: String
    let keys: BSONDocument

    func execute(
        on collection: MongoCollection<BSONDocument>,
        sessions: [String: ClientSession]
    ) throws -> TestOperationResult? {
        let indexOptions = IndexOptions(name: self.name)
        _ = try collection.createIndex(self.keys, indexOptions: indexOptions, session: sessions[self.session ?? ""])
        return nil
    }
}
