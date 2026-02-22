import XCTest
@testable import Fleet

final class FirestoreSyncErrorTests: XCTestCase {

    // MARK: - Error Description

    func testPartialSyncFailureDescription() {
        let error = FirestoreSyncError.partialSyncFailure(details: "Tesla Model 3: network timeout")
        XCTAssertEqual(error.errorDescription, "Some vehicles failed to sync: Tesla Model 3: network timeout")
    }

    func testPartialSyncFailureEmptyDetails() {
        let error = FirestoreSyncError.partialSyncFailure(details: "")
        XCTAssertEqual(error.errorDescription, "Some vehicles failed to sync: ")
    }

    func testPartialSyncFailureMultipleDetails() {
        let details = "Tesla Model 3: timeout; BMW M4: permission denied"
        let error = FirestoreSyncError.partialSyncFailure(details: details)
        XCTAssertTrue(error.errorDescription?.contains("Tesla Model 3") ?? false)
        XCTAssertTrue(error.errorDescription?.contains("BMW M4") ?? false)
    }

    // MARK: - LocalizedError Conformance

    func testConformsToLocalizedError() {
        let error: LocalizedError = FirestoreSyncError.partialSyncFailure(details: "test")
        XCTAssertNotNil(error.errorDescription)
    }

    func testConformsToError() {
        let error: Error = FirestoreSyncError.partialSyncFailure(details: "test")
        XCTAssertFalse(error.localizedDescription.isEmpty)
    }

    // MARK: - Edge Cases

    func testVeryLongDetails() {
        let longDetails = String(repeating: "x", count: 10_000)
        let error = FirestoreSyncError.partialSyncFailure(details: longDetails)
        XCTAssertTrue(error.errorDescription?.count ?? 0 > 10_000)
    }

    func testUnicodeDetails() {
        let error = FirestoreSyncError.partialSyncFailure(details: "\u{8C50}\u{7530} Camry: \u{5931}\u{6557}")
        XCTAssertTrue(error.errorDescription?.contains("\u{8C50}\u{7530}") ?? false)
    }

    func testSpecialCharactersInDetails() {
        let error = FirestoreSyncError.partialSyncFailure(details: "Error: <timeout> & 'connection refused'")
        XCTAssertTrue(error.errorDescription?.contains("<timeout>") ?? false)
    }
}
