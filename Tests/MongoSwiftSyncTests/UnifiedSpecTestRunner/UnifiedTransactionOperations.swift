import Foundation
import MongoSwiftSync
import TestsCommon

struct StartTransactionOperation: UnifiedOperationProtocol {}

struct CommitTransactionOperation: UnifiedOperationProtocol {}

struct AbortTransactionOperation: UnifiedOperationProtocol {}
