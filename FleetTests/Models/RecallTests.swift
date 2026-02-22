import XCTest
@testable import Fleet

final class RecallTests: XCTestCase {

    // MARK: - Initialization

    func testBasicInitialization() {
        let id = UUID()
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let recall = Recall(id: id, title: "Brake Pad", details: "Front brake pads may fail", source: "NHTSA", dateIssued: date, isResolved: false)

        XCTAssertEqual(recall.id, id)
        XCTAssertEqual(recall.title, "Brake Pad")
        XCTAssertEqual(recall.details, "Front brake pads may fail")
        XCTAssertEqual(recall.source, "NHTSA")
        XCTAssertEqual(recall.dateIssued, date)
        XCTAssertFalse(recall.isResolved)
    }

    func testResolvedRecall() {
        let recall = Recall(id: UUID(), title: "Test", details: "", source: "", dateIssued: Date(), isResolved: true)
        XCTAssertTrue(recall.isResolved)
    }

    // MARK: - isResolved Toggle

    func testToggleIsResolved() {
        var recall = Recall(id: UUID(), title: "Test", details: "", source: "", dateIssued: Date(), isResolved: false)
        XCTAssertFalse(recall.isResolved)
        recall.isResolved = true
        XCTAssertTrue(recall.isResolved)
        recall.isResolved = false
        XCTAssertFalse(recall.isResolved)
    }

    // MARK: - Formatted Date

    func testFormattedDate() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = DateComponents(year: 2025, month: 3, day: 15)
        let date = calendar.date(from: components)!
        let recall = Recall(id: UUID(), title: "Test", details: "", source: "", dateIssued: date, isResolved: false)
        // formattedDate uses local DateFormatter, just make sure it's not empty
        XCTAssertFalse(recall.formattedDate.isEmpty)
    }

    func testFormattedDateNotEmpty() {
        let recall = Recall(id: UUID(), title: "Test", details: "", source: "", dateIssued: Date(), isResolved: false)
        XCTAssertFalse(recall.formattedDate.isEmpty)
    }

    // MARK: - Identifiable

    func testIdentifiable() {
        let id = UUID()
        let recall = Recall(id: id, title: "Test", details: "", source: "", dateIssued: Date(), isResolved: false)
        XCTAssertEqual(recall.id, id)
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        let original = Recall(id: UUID(), title: "FSD Safety", details: "Full Self-Driving Beta recall", source: "NHTSA", dateIssued: Date(timeIntervalSince1970: 1_700_000_000), isResolved: false)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Recall.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.title, original.title)
        XCTAssertEqual(decoded.details, original.details)
        XCTAssertEqual(decoded.source, original.source)
        XCTAssertEqual(decoded.dateIssued, original.dateIssued)
        XCTAssertEqual(decoded.isResolved, original.isResolved)
    }

    // MARK: - Edge Cases

    func testEmptyStrings() {
        let recall = Recall(id: UUID(), title: "", details: "", source: "", dateIssued: Date(), isResolved: false)
        XCTAssertEqual(recall.title, "")
        XCTAssertEqual(recall.details, "")
        XCTAssertEqual(recall.source, "")
    }

    func testVeryLongTitle() {
        let longTitle = String(repeating: "X", count: 10_000)
        let recall = Recall(id: UUID(), title: longTitle, details: "", source: "", dateIssued: Date(), isResolved: false)
        XCTAssertEqual(recall.title.count, 10_000)
    }

    func testUnicodeInTitle() {
        let recall = Recall(id: UUID(), title: "\u{26A0}\u{FE0F} \u{5371}\u{9669} Danger", details: "", source: "", dateIssued: Date(), isResolved: false)
        XCTAssertTrue(recall.title.contains("\u{5371}\u{9669}"))
    }

    func testEpochDate() {
        let recall = Recall(id: UUID(), title: "Old", details: "", source: "", dateIssued: Date(timeIntervalSince1970: 0), isResolved: false)
        XCTAssertEqual(recall.dateIssued, Date(timeIntervalSince1970: 0))
    }

    func testFarFutureDate() {
        let farFuture = Date(timeIntervalSince1970: 4_000_000_000) // ~2096
        let recall = Recall(id: UUID(), title: "Future", details: "", source: "", dateIssued: farFuture, isResolved: false)
        XCTAssertEqual(recall.dateIssued, farFuture)
    }

    func testMutability() {
        var recall = Recall(id: UUID(), title: "Original", details: "D1", source: "S1", dateIssued: Date(), isResolved: false)
        recall.title = "Updated"
        recall.details = "D2"
        recall.source = "S2"
        XCTAssertEqual(recall.title, "Updated")
        XCTAssertEqual(recall.details, "D2")
        XCTAssertEqual(recall.source, "S2")
    }
}
