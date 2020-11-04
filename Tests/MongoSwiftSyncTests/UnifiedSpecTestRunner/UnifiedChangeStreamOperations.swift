import Foundation
import MongoSwiftSync

 /// Creates a change stream and ensures that the server-side cursor has been created.
struct CreateChangeStreamOperation: UnifiedOperationProtocol {
    /// Pipeline to use when creating the change stream.
    let pipeline: [BSONDocument]

    /// Options to use when creating the change stream.
    let options: ChangeStreamOptions

    enum CodingKeys: String, CodingKey, CaseIterable {
        case pipeline
    }

    static var knownArguments: Set<String> {
        Set(
            CodingKeys.allCases.map { $0.rawValue } +
            Mirror(reflecting: ChangeStreamOptions()).children.map { $0.label! }
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pipeline = try container.decode([BSONDocument].self, forKey: .pipeline)
        self.options = try ChangeStreamOptions(from: decoder)
    }
}

/// Iterates the change stream until either a single document is returned or an error is raised.
struct IterateUntilDocumentOrErrorOperation: UnifiedOperationProtocol {
    static var knownArguments: Set<String> { Set() }
}
