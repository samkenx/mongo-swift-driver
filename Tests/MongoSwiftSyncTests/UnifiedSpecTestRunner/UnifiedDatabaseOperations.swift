import Foundation
import MongoSwiftSync

struct DropCollectionOperation: UnifiedOperationProtocol {
    /// Collection name.
    let collection: String

    /// Session to use for the operation.
    let session: String?

    static var knownArguments: Set<String> { ["collection", "session"] }
}

struct CreateCollectionOperation: UnifiedOperationProtocol {
    /// Collection name.
    let collection: String

    /// Session to use for the operation.
    let session: String?

    static var knownArguments: Set<String> { ["collection", "session"] }
}
