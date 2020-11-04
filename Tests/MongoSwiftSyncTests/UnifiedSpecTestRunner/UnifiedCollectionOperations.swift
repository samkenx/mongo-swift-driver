import Foundation
import MongoSwiftSync
@testable import struct MongoSwift.FindOptions

struct AggregateOperation: UnifiedOperationProtocol {
    /// Aggregation pipeline.
    let pipeline: [BSONDocument]

    /// Session to use for the operation.
    let session: String?
    
    let options: AggregateOptions? // todo: nil if empty?

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case pipeline, session
    }

    static var knownArguments: Set<String> {
        Set(
            CodingKeys.allCases.map { $0.rawValue } +
            Mirror(reflecting: AggregateOptions()).children.map { $0.label! }
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pipeline = try container.decode([BSONDocument].self, forKey: .pipeline)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.options = try AggregateOptions(from: decoder)
    }
}

struct FindOperation: UnifiedOperationProtocol {
    /// Filter to use for the query.
    let filter: BSONDocument

    /// Session to use for the operation.
    let session: String?

    /// Options to use when executing the command.
    let options: FindOptions?

    enum CodingKeys: String, CodingKey, CaseIterable {
        case filter, session
    }

    static var knownArguments: Set<String> {
        Set(
            CodingKeys.allCases.map { $0.rawValue } +
            FindOptions.CodingKeys.allCases.map { $0.rawValue }
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.filter = try container.decode(BSONDocument.self, forKey: .filter)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.options = try FindOptions(from: decoder) // todo: nil if empty?
    }
}

struct InsertOneOperation:  UnifiedOperationProtocol {
    /// Document to insert.
    let document: BSONDocument

    /// Identifier for a session to use.
    let session: String?

    /// Options to use when executing the command.
    let options: InsertOneOptions?

    enum CodingKeys: String, CodingKey, CaseIterable {
        case document, session
    }

    static var knownArguments: Set<String> {
        Set(
            CodingKeys.allCases.map { $0.rawValue } +
            Mirror(reflecting: InsertOneOptions()).children.map { $0.label! }
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.document = try container.decode(BSONDocument.self, forKey: .document)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.options = try InsertOneOptions(from: decoder) // todo: nil if empty?
    }
}

struct InsertManyOperation: UnifiedOperationProtocol {
    /// Document to insert.
    let documents: [BSONDocument]

    /// Session to use for the operation.
    let session: String?

    /// Options to use when executing the command.
    let options: InsertManyOptions?

    enum CodingKeys: String, CodingKey, CaseIterable {
        case documents, session
    }

    static var knownArguments: Set<String> {
        Set(
            CodingKeys.allCases.map { $0.rawValue } +
            Mirror(reflecting: InsertManyOptions()).children.map { $0.label! }
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.documents = try container.decode([BSONDocument].self, forKey: .documents)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.options = try InsertManyOptions(from: decoder) // todo: nil if empty?
    }
}

/// Describes modifications to make during an `update`.
enum UpdateModification: Decodable {
    case document(BSONDocument)
    // todo: we don't actually support pipelines so probably need to error/skip this case
    case pipeline([BSONDocument])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let doc = try? container.decode(BSONDocument.self) {
            self = .document(doc)
        } else {
            let pipeline = try container.decode([BSONDocument].self)
            self = .pipeline(pipeline)
        }
    }
}

struct FindOneAndUpdateOperation: UnifiedOperationProtocol {
    /// Filter to use.
    let filter: BSONDocument

    /// Describes updates to make.
    let update: UpdateModification

    /// Session to use.
    let session: String?

    /// Options to use when executing the command.
    let options: FindOneAndUpdateOptions?

    enum CodingKeys: String, CodingKey, CaseIterable {
        case filter, update, session
    }

    static var knownArguments: Set<String> {
        Set(
            CodingKeys.allCases.map { $0.rawValue } +
            Mirror(reflecting: FindOneAndUpdateOptions()).children.map { $0.label! }
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.filter = try container.decode(BSONDocument.self, forKey: .filter)
        self.update =  try container.decode(UpdateModification.self, forKey: .update)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.options = try FindOneAndUpdateOptions(from: decoder) // todo: nil if empty?
    }
}

// todo: ensure no extra fields
struct FindOneAndReplaceOperation: UnifiedOperationProtocol {
    /// Filter to use.
    let filter: BSONDocument

    /// Replacement document.
    let replacement: BSONDocument

    /// Session to use.
    let session: String?

    /// Options to use when executing the command.
    let options: FindOneAndReplaceOptions?

    enum CodingKeys: String, CodingKey, CaseIterable {
        case filter, replacement, session
    }

    static var knownArguments: Set<String> {
        Set(
            CodingKeys.allCases.map { $0.rawValue } +
            Mirror(reflecting: FindOneAndReplaceOptions()).children.map { $0.label! }
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.filter = try container.decode(BSONDocument.self, forKey: .filter)
        self.replacement =  try container.decode(BSONDocument.self, forKey: .replacement)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.options = try FindOneAndReplaceOptions(from: decoder) // todo: nil if empty?
    }
}

struct CreateIndexOperation: UnifiedOperationProtocol {
    /// Name for the index.
    let name: String

    /// Keys for the index.
    let keys: BSONDocument

    /// Session to use.
    let session: String?
    
    static var knownArguments: Set<String> {
        Set(["name", "keys", "session"])
    }
}

struct BulkWriteOperation: UnifiedOperationProtocol {
    let requests: [WriteModel<BSONDocument>]

    let options: BulkWriteOptions // todo: nil if empty?

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case requests
    }

    static var knownArguments: Set<String> {
        Set(
            CodingKeys.allCases.map { $0.rawValue } +
            Mirror(reflecting: BulkWriteOptions()).children.map { $0.label! }
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.requests = try container.decode([WriteModel<BSONDocument>].self, forKey: .requests)
        self.options = try BulkWriteOptions(from: decoder)
    }
}

struct ReplaceOneOperation: UnifiedOperationProtocol {
    /// Filter for the query.
    let filter: BSONDocument

    /// Replacement document.
    let replacement: BSONDocument

    /// Session to use for the operation.
    let session: String?
    
    let options: ReplaceOptions? // todo: nil if empty?

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case filter, replacement, session
    }

    static var knownArguments: Set<String> {
        Set(
            CodingKeys.allCases.map { $0.rawValue } +
            Mirror(reflecting: ReplaceOptions()).children.map { $0.label! }
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.filter = try container.decode(BSONDocument.self, forKey: .filter)
        self.replacement = try container.decode(BSONDocument.self, forKey: .replacement)
        self.session = try container.decodeIfPresent(String.self, forKey: .session)
        self.options = try ReplaceOptions(from: decoder)
    }
}

