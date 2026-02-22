import XCTest
@testable import Fleet

final class RegistrationInfoTests: XCTestCase {

    // MARK: - Initialization

    func testBasicInitialization() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let reg = RegistrationInfo(expiryDate: date, state: "CA")

        XCTAssertEqual(reg.expiryDate, date)
        XCTAssertEqual(reg.state, "CA")
    }

    // MARK: - Days Until Expiry

    func testDaysUntilExpiryFuture() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 90, to: Date())!
        let reg = RegistrationInfo(expiryDate: futureDate, state: "CA")
        // Allow 1-day tolerance due to time-of-day differences
        XCTAssertTrue(reg.daysUntilExpiry >= 89 && reg.daysUntilExpiry <= 91)
    }

    func testDaysUntilExpiryPast() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let reg = RegistrationInfo(expiryDate: pastDate, state: "CA")
        XCTAssertTrue(reg.daysUntilExpiry <= 0)
    }

    func testDaysUntilExpiryToday() {
        let reg = RegistrationInfo(expiryDate: Date(), state: "CA")
        XCTAssertTrue(reg.daysUntilExpiry <= 1 && reg.daysUntilExpiry >= -1)
    }

    // MARK: - isExpiringSoon

    func testIsExpiringSoonWithin30Days() {
        let soonDate = Calendar.current.date(byAdding: .day, value: 15, to: Date())!
        let reg = RegistrationInfo(expiryDate: soonDate, state: "CA")
        XCTAssertTrue(reg.isExpiringSoon)
    }

    func testIsNotExpiringSoonBeyond30Days() {
        let farDate = Calendar.current.date(byAdding: .day, value: 60, to: Date())!
        let reg = RegistrationInfo(expiryDate: farDate, state: "CA")
        XCTAssertFalse(reg.isExpiringSoon)
    }

    func testIsNotExpiringSoonIfExpired() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let reg = RegistrationInfo(expiryDate: pastDate, state: "CA")
        // isExpiringSoon requires daysUntilExpiry > 0, so expired = not "expiring soon"
        XCTAssertFalse(reg.isExpiringSoon)
    }

    func testIsExpiringSoonBoundaryAt29Days() {
        let date = Calendar.current.date(byAdding: .day, value: 29, to: Date())!
        let reg = RegistrationInfo(expiryDate: date, state: "CA")
        XCTAssertTrue(reg.isExpiringSoon)
    }

    func testIsNotExpiringSoonBoundaryAt31Days() {
        let date = Calendar.current.date(byAdding: .day, value: 31, to: Date())!
        let reg = RegistrationInfo(expiryDate: date, state: "CA")
        XCTAssertFalse(reg.isExpiringSoon)
    }

    // MARK: - isExpired

    func testIsExpired() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let reg = RegistrationInfo(expiryDate: pastDate, state: "CA")
        XCTAssertTrue(reg.isExpired)
    }

    func testIsNotExpired() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 60, to: Date())!
        let reg = RegistrationInfo(expiryDate: futureDate, state: "CA")
        XCTAssertFalse(reg.isExpired)
    }

    // MARK: - Status Text

    func testStatusTextActive() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 60, to: Date())!
        let reg = RegistrationInfo(expiryDate: futureDate, state: "CA")
        XCTAssertEqual(reg.statusText, "Active")
    }

    func testStatusTextExpired() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let reg = RegistrationInfo(expiryDate: pastDate, state: "CA")
        XCTAssertEqual(reg.statusText, "Expired")
    }

    func testStatusTextExpiringSoon() {
        let soonDate = Calendar.current.date(byAdding: .day, value: 15, to: Date())!
        let reg = RegistrationInfo(expiryDate: soonDate, state: "CA")
        XCTAssertTrue(reg.statusText.hasPrefix("Expires in"))
        XCTAssertTrue(reg.statusText.hasSuffix("days"))
    }

    // MARK: - Formatted Date

    func testFormattedDateNotEmpty() {
        let reg = RegistrationInfo(expiryDate: Date(), state: "CA")
        XCTAssertFalse(reg.formattedDate.isEmpty)
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        let original = RegistrationInfo(expiryDate: Date(timeIntervalSince1970: 1_700_000_000), state: "NY")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RegistrationInfo.self, from: data)

        XCTAssertEqual(decoded.expiryDate, original.expiryDate)
        XCTAssertEqual(decoded.state, original.state)
    }

    // MARK: - Edge Cases

    func testEmptyState() {
        let reg = RegistrationInfo(expiryDate: Date(), state: "")
        XCTAssertEqual(reg.state, "")
    }

    func testLongStateName() {
        let reg = RegistrationInfo(expiryDate: Date(), state: "District of Columbia")
        XCTAssertEqual(reg.state, "District of Columbia")
    }

    func testUnicodeState() {
        let reg = RegistrationInfo(expiryDate: Date(), state: "\u{30AB}\u{30EA}\u{30D5}\u{30A9}\u{30EB}\u{30CB}\u{30A2}")
        XCTAssertEqual(reg.state, "\u{30AB}\u{30EA}\u{30D5}\u{30A9}\u{30EB}\u{30CB}\u{30A2}")
    }

    func testVeryFarFutureExpiry() {
        let farFuture = Date(timeIntervalSince1970: 4_000_000_000)
        let reg = RegistrationInfo(expiryDate: farFuture, state: "CA")
        XCTAssertFalse(reg.isExpired)
        XCTAssertFalse(reg.isExpiringSoon)
    }

    func testEpochExpiry() {
        let epoch = Date(timeIntervalSince1970: 0)
        let reg = RegistrationInfo(expiryDate: epoch, state: "CA")
        XCTAssertTrue(reg.isExpired)
    }

    func testMutability() {
        var reg = RegistrationInfo(expiryDate: Date(), state: "CA")
        reg.state = "NY"
        XCTAssertEqual(reg.state, "NY")
        let newDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        reg.expiryDate = newDate
        XCTAssertEqual(reg.expiryDate, newDate)
    }
}
