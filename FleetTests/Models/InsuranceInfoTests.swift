import XCTest
@testable import Fleet

final class InsuranceInfoTests: XCTestCase {

    // MARK: - Initialization

    func testBasicInitialization() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let ins = InsuranceInfo(provider: "State Farm", coverageType: "Full", expiryDate: date)

        XCTAssertEqual(ins.provider, "State Farm")
        XCTAssertEqual(ins.coverageType, "Full")
        XCTAssertEqual(ins.expiryDate, date)
    }

    // MARK: - Days Until Expiry

    func testDaysUntilExpiryFuture() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 90, to: Date())!
        let ins = InsuranceInfo(provider: "Test", coverageType: "Full", expiryDate: futureDate)
        XCTAssertTrue(ins.daysUntilExpiry >= 89 && ins.daysUntilExpiry <= 91)
    }

    func testDaysUntilExpiryPast() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let ins = InsuranceInfo(provider: "Test", coverageType: "Full", expiryDate: pastDate)
        XCTAssertTrue(ins.daysUntilExpiry <= 0)
    }

    // MARK: - isActive

    func testIsActiveWhenFuture() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 90, to: Date())!
        let ins = InsuranceInfo(provider: "Test", coverageType: "Full", expiryDate: futureDate)
        XCTAssertTrue(ins.isActive)
    }

    func testIsNotActiveWhenExpired() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let ins = InsuranceInfo(provider: "Test", coverageType: "Full", expiryDate: pastDate)
        XCTAssertFalse(ins.isActive)
    }

    // MARK: - Status Text

    func testStatusText() {
        let ins = InsuranceInfo(provider: "Geico", coverageType: "Comprehensive", expiryDate: Date())
        XCTAssertEqual(ins.statusText, "Geico \u{00B7} Comprehensive")
    }

    func testStatusTextEmptyProvider() {
        let ins = InsuranceInfo(provider: "", coverageType: "Full", expiryDate: Date())
        XCTAssertEqual(ins.statusText, " \u{00B7} Full")
    }

    func testStatusTextEmptyCoverage() {
        let ins = InsuranceInfo(provider: "State Farm", coverageType: "", expiryDate: Date())
        XCTAssertEqual(ins.statusText, "State Farm \u{00B7} ")
    }

    // MARK: - Formatted Date

    func testFormattedDateNotEmpty() {
        let ins = InsuranceInfo(provider: "Test", coverageType: "Full", expiryDate: Date())
        XCTAssertFalse(ins.formattedDate.isEmpty)
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        let original = InsuranceInfo(provider: "Progressive", coverageType: "Liability", expiryDate: Date(timeIntervalSince1970: 1_700_000_000))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(InsuranceInfo.self, from: data)

        XCTAssertEqual(decoded.provider, original.provider)
        XCTAssertEqual(decoded.coverageType, original.coverageType)
        XCTAssertEqual(decoded.expiryDate, original.expiryDate)
    }

    // MARK: - Edge Cases

    func testEmptyStrings() {
        let ins = InsuranceInfo(provider: "", coverageType: "", expiryDate: Date())
        XCTAssertEqual(ins.provider, "")
        XCTAssertEqual(ins.coverageType, "")
    }

    func testVeryLongProvider() {
        let longName = String(repeating: "P", count: 10_000)
        let ins = InsuranceInfo(provider: longName, coverageType: "Full", expiryDate: Date())
        XCTAssertEqual(ins.provider.count, 10_000)
    }

    func testUnicodeProvider() {
        let ins = InsuranceInfo(provider: "\u{4FDD}\u{967A}\u{4F1A}\u{793E}", coverageType: "\u{5168}\u{984D}", expiryDate: Date())
        XCTAssertEqual(ins.provider, "\u{4FDD}\u{967A}\u{4F1A}\u{793E}")
        XCTAssertEqual(ins.coverageType, "\u{5168}\u{984D}")
    }

    func testEpochExpiry() {
        let ins = InsuranceInfo(provider: "Test", coverageType: "Full", expiryDate: Date(timeIntervalSince1970: 0))
        XCTAssertFalse(ins.isActive)
    }

    func testFarFutureExpiry() {
        let farFuture = Date(timeIntervalSince1970: 4_000_000_000)
        let ins = InsuranceInfo(provider: "Test", coverageType: "Full", expiryDate: farFuture)
        XCTAssertTrue(ins.isActive)
    }

    func testMutability() {
        var ins = InsuranceInfo(provider: "Old", coverageType: "Basic", expiryDate: Date())
        ins.provider = "New"
        ins.coverageType = "Premium"
        XCTAssertEqual(ins.provider, "New")
        XCTAssertEqual(ins.coverageType, "Premium")
    }

    func testSpecialCharactersInProvider() {
        let ins = InsuranceInfo(provider: "O'Brien & Sons (Inc.)", coverageType: "Full/Comp", expiryDate: Date())
        XCTAssertEqual(ins.provider, "O'Brien & Sons (Inc.)")
        XCTAssertEqual(ins.coverageType, "Full/Comp")
    }
}
