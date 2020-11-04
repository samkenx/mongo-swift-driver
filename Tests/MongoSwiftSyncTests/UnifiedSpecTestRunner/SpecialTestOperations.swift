import Foundation
@testable import MongoSwiftSync

struct FailPointOperation: UnifiedOperationProtocol {
    /// The `configureFailPoint` command to be executed.
    let failPoint: BSONDocument

    /// Identifier for the client to set the failpoint on.
    // why is this necessary if there is also an entity specified with the oepration?
    let client: String

    static var knownArguments: Set<String> {
        Set(["failPoint", "client"])
    }
}

struct TargetedFailPointOperation: UnifiedOperationProtocol {
    /// The `configureFailPoint` command to be executed.
    let failPoint: BSONDocument

    /// Identifier for the session with which to set the fail point.
    let session: String

    static var knownArguments: Set<String> {
        Set(["failPoint", "session"])
    }
}

// todo: ensure no extra fields
struct AssertSessionTransactionStateOperation: UnifiedOperationProtocol {
    /// Identifier for the session to perform the operation on.
    let session: String
    /// Expected transaction state for the session.
    let state: ClientSession.TransactionState

    static var knownArguments: Set<String> {
        Set(["session", "state"])
    }
}

// todo: ensure no extra fields
struct AssertSessionPinnedOperation: UnifiedOperationProtocol {
    /// Identifier for the session to perform the assertion on.
    let session: String

    static var knownArguments: Set<String> {
        Set(["session"])
    }
}

// todo: ensure no extra fields
struct AssertSessionUnpinnedOperation: UnifiedOperationProtocol {
    /// Identifier for the session to perform the assertion on.
    let session: String

    static var knownArguments: Set<String> {
        Set(["session"])
    }
}

// todo: ensure no extra fields
struct AssertDifferentLsidOnLastTwoCommandsOperation: UnifiedOperationProtocol {
    /// Identifier for the client to perform the assertion on.
    let client: String

    static var knownArguments: Set<String> {
        Set(["client"])
    }
}

// todo: ensure no extra fields
struct AssertSameLsidOnLastTwoCommandsOperation: UnifiedOperationProtocol {
    /// Identifier for the client to perform the assertion on.
    let client: String

    static var knownArguments: Set<String> {
        Set(["client"])
    }
}

struct AssertSessionNotDirtyOperation: UnifiedOperationProtocol {
    /// Identifier for the session to perform the assertion on.
    let session: String

    static var knownArguments: Set<String> {
        Set(["failPoint", "session"])
    }
}

struct AssertSessionDirtyOperation: UnifiedOperationProtocol {
    /// Identifier for the session to perform the assertion on.
    let session: String

    static var knownArguments: Set<String> {
        Set(["failPoint", "session"])
    }
}

// todo: ensure no extra fields
struct AssertCollectionExistsOperation: UnifiedOperationProtocol {
    /// The name of the collection.
    let collectionName: String

    /// The name of the database.
    let databaseName: String

    static var knownArguments: Set<String> {
        Set(["collectionName", "databaseName"])
    }
}

// todo: ensure no extra fields
struct AssertCollectionNotExistsOperation: UnifiedOperationProtocol {
    /// The name of the collection.
    let collectionName: String

    /// The name of the database.
    let databaseName: String

    static var knownArguments: Set<String> {
        Set(["collectionName", "databaseName"])
    }
}

// todo: ensure no extra fields
struct AssertIndexExistsOperation: UnifiedOperationProtocol {
    /// The name of the collection.
    let collectionName: String

    /// The name of the database.
    let databaseName: String
    
    /// The name of the index.
    let indexName: String

    static var knownArguments: Set<String> {
        Set(["collectionName", "databaseName", "indexName"])
    }
}

// todo: ensure no extra fields
struct AssertIndexNotExistsOperation: UnifiedOperationProtocol {
    /// The name of the collection.
    let collectionName: String

    /// The name of the database.
    let databaseName: String
    
    /// The name of the index.
    let indexName: String

    static var knownArguments: Set<String> {
        Set(["collectionName", "databaseName", "indexName"])
    }
}
