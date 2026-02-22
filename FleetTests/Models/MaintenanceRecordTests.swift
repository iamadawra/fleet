import XCTest
@testable import Fleet

final class MaintenanceRecordTests: XCTestCase {

    // MARK: - Initialization

    func testBasicInitialization() {
        let id = UUID()
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let record = MaintenanceRecord(id: id, title: "Oil Change", date: date, provider: "Jiffy Lube", isCompleted: true, mileage: 50000)

        XCTAssertEqual(record.id, id)
        XCTAssertEqual(record.title, "Oil Change")
        XCTAssertEqual(record.date, date)
        XCTAssertEqual(record.provider, "Jiffy Lube")
        XCTAssertTrue(record.isCompleted)
        XCTAssertEqual(record.mileage, 50000)
    }

    func testNilMileage() {
        let record = MaintenanceRecord(id: UUID(), title: "Inspection", date: Date(), provider: "Dealer", isCompleted: false, mileage: nil)
        XCTAssertNil(record.mileage)
    }

    // MARK: - isCompleted State

    func testCompletedState() {
        let record = MaintenanceRecord(id: UUID(), title: "Test", date: Date(), provider: "", isCompleted: true, mileage: nil)
        XCTAssertTrue(record.isCompleted)
    }

    func testNotCompletedState() {
        let record = MaintenanceRecord(id: UUID(), title: "Test", date: Date(), provider: "", isCompleted: false, mileage: nil)
        XCTAssertFalse(record.isCompleted)
    }

    func testToggleCompleted() {
        var record = MaintenanceRecord(id: UUID(), title: "Test", date: Date(), provider: "", isCompleted: false, mileage: nil)
        XCTAssertFalse(record.isCompleted)
        record.isCompleted = true
        XCTAssertTrue(record.isCompleted)
    }

    // MARK: - Formatted Date

    func testFormattedDateNotEmpty() {
        let record = MaintenanceRecord(id: UUID(), title: "Test", date: Date(), provider: "", isCompleted: true, mileage: nil)
        XCTAssertFalse(record.formattedDate.isEmpty)
    }

    // MARK: - Status Text

    func testStatusTextCompleted() {
        let record = MaintenanceRecord(id: UUID(), title: "Test", date: Date(), provider: "", isCompleted: true, mileage: nil)
        XCTAssertEqual(record.statusText, "Completed")
    }

    func testStatusTextNotCompleted() {
        let futureDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())!
        let record = MaintenanceRecord(id: UUID(), title: "Test", date: futureDate, provider: "", isCompleted: false, mileage: nil)
        XCTAssertTrue(record.statusText.hasPrefix("Due"))
        XCTAssertTrue(record.statusText.contains("~"))
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        let original = MaintenanceRecord(id: UUID(), title: "Brake Pads", date: Date(timeIntervalSince1970: 1_700_000_000), provider: "AutoZone", isCompleted: true, mileage: 30000)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MaintenanceRecord.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.title, original.title)
        XCTAssertEqual(decoded.date, original.date)
        XCTAssertEqual(decoded.provider, original.provider)
        XCTAssertEqual(decoded.isCompleted, original.isCompleted)
        XCTAssertEqual(decoded.mileage, original.mileage)
    }

    func testCodableRoundTripNilMileage() throws {
        let original = MaintenanceRecord(id: UUID(), title: "Check", date: Date(timeIntervalSince1970: 1_700_000_000), provider: "Shop", isCompleted: false, mileage: nil)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MaintenanceRecord.self, from: data)

        XCTAssertNil(decoded.mileage)
    }

    // MARK: - Edge Cases

    func testEmptyStrings() {
        let record = MaintenanceRecord(id: UUID(), title: "", date: Date(), provider: "", isCompleted: false, mileage: nil)
        XCTAssertEqual(record.title, "")
        XCTAssertEqual(record.provider, "")
    }

    func testVeryLongTitle() {
        let longTitle = String(repeating: "M", count: 10_000)
        let record = MaintenanceRecord(id: UUID(), title: longTitle, date: Date(), provider: "", isCompleted: false, mileage: nil)
        XCTAssertEqual(record.title.count, 10_000)
    }

    func testNegativeMileage() {
        let record = MaintenanceRecord(id: UUID(), title: "Test", date: Date(), provider: "", isCompleted: false, mileage: -500)
        XCTAssertEqual(record.mileage, -500)
    }

    func testVeryLargeMileage() {
        let record = MaintenanceRecord(id: UUID(), title: "Test", date: Date(), provider: "", isCompleted: false, mileage: Int.max)
        XCTAssertEqual(record.mileage, Int.max)
    }

    func testZeroMileage() {
        let record = MaintenanceRecord(id: UUID(), title: "Test", date: Date(), provider: "", isCompleted: false, mileage: 0)
        XCTAssertEqual(record.mileage, 0)
    }

    func testEpochDate() {
        let epoch = Date(timeIntervalSince1970: 0)
        let record = MaintenanceRecord(id: UUID(), title: "Old", date: epoch, provider: "", isCompleted: true, mileage: nil)
        XCTAssertEqual(record.date, epoch)
    }

    func testFarFutureDate() {
        let farFuture = Date(timeIntervalSince1970: 4_000_000_000)
        let record = MaintenanceRecord(id: UUID(), title: "Future", date: farFuture, provider: "", isCompleted: false, mileage: nil)
        XCTAssertEqual(record.date, farFuture)
    }

    func testUnicodeInProvider() {
        let record = MaintenanceRecord(id: UUID(), title: "Test", date: Date(), provider: "\u{30C8}\u{30E8}\u{30BF}\u{30C7}\u{30A3}\u{30FC}\u{30E9}\u{30FC}", isCompleted: true, mileage: nil)
        XCTAssertEqual(record.provider, "\u{30C8}\u{30E8}\u{30BF}\u{30C7}\u{30A3}\u{30FC}\u{30E9}\u{30FC}")
    }

    func testMutability() {
        var record = MaintenanceRecord(id: UUID(), title: "Original", date: Date(), provider: "Shop1", isCompleted: false, mileage: 1000)
        record.title = "Updated"
        record.provider = "Shop2"
        record.mileage = 2000
        XCTAssertEqual(record.title, "Updated")
        XCTAssertEqual(record.provider, "Shop2")
        XCTAssertEqual(record.mileage, 2000)
    }

    // MARK: - Identifiable

    func testIdentifiable() {
        let id = UUID()
        let record = MaintenanceRecord(id: id, title: "Test", date: Date(), provider: "", isCompleted: false, mileage: nil)
        XCTAssertEqual(record.id, id)
    }
}
