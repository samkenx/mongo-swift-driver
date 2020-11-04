import MongoSwiftSync
import Nimble
import TestsCommon

final class UnifiedTests: MongoSwiftTestCase {
    override func setUp() {
        self.continueAfterFailure = false
    }

    func testUnifiedRunner() throws {
        // We don't support either of these APIs.
        let skipValidPassTests = [
            "poc-gridfs.json",
            "poc-transactions-convenient-api.json"
        ]

        let validPassTests = try retrieveSpecTestFiles(
            specName: "unified-test-format",
            subdirectory: "valid-pass",
            excludeFiles: skipValidPassTests,
            asType: UnifiedTestFile.self
        )

        let skipValidFailTests = [
            // Because we use an enum to represent ReturnDocument, the invalid string present in this file "Invalid"
            // gives us a decoding error, and therefore we cannot decode it.
            "returnDocument-enum-invalid.json"
        ]

        // for all other tests verify that they result in an error while trying to run them.
        let validFailTests = try retrieveSpecTestFiles(
            specName: "unified-test-format",
            subdirectory: "valid-fail",
            excludeFiles: skipValidFailTests,
            asType: UnifiedTestFile.self
        )

        let runner = try UnifiedTestRunner()
        try runner.runFiles(validPassTests.map { $0.1 })

        // for (filename, file) in validFailTests {
        //     expect(try file.run()).to(throwError(), description: filename)
        // }
    }
}
