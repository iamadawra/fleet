import XCTest
@testable import Fleet

final class ValuationTests: XCTestCase {

    // MARK: - Initialization

    func testBasicInitialization() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let trend = ValuationTrend(amount: 500, direction: .up, summary: "Market up")
        let valuation = Valuation(tradeIn: 25000, privateSale: 30000, dealer: 33000, trend: trend, lastUpdated: date)

        XCTAssertEqual(valuation.tradeIn, 25000)
        XCTAssertEqual(valuation.privateSale, 30000)
        XCTAssertEqual(valuation.dealer, 33000)
        XCTAssertEqual(valuation.trend.amount, 500)
        XCTAssertEqual(valuation.trend.direction, .up)
        XCTAssertEqual(valuation.trend.summary, "Market up")
        XCTAssertEqual(valuation.lastUpdated, date)
    }

    // MARK: - Formatted Values

    func testFormattedTradeIn() {
        let val = Valuation(tradeIn: 29000, privateSale: 34000, dealer: 37000, trend: ValuationTrend(amount: 0, direction: .up, summary: ""), lastUpdated: Date())
        XCTAssertEqual(val.formattedTradeIn, "$29k")
    }

    func testFormattedTradeInSmallValue() {
        let val = Valuation(tradeIn: 500, privateSale: 1000, dealer: 1500, trend: ValuationTrend(amount: 0, direction: .up, summary: ""), lastUpdated: Date())
        XCTAssertEqual(val.formattedTradeIn, "$0k")
    }

    func testFormattedDealer() {
        let val = Valuation(tradeIn: 25000, privateSale: 30000, dealer: 72000, trend: ValuationTrend(amount: 0, direction: .up, summary: ""), lastUpdated: Date())
        XCTAssertEqual(val.formattedDealer, "$72k")
    }

    func testFormattedPrivateSale() {
        let val = Valuation(tradeIn: 25000, privateSale: 34200, dealer: 37000, trend: ValuationTrend(amount: 0, direction: .up, summary: ""), lastUpdated: Date())
        // formattedPrivateSale uses the currency NumberFormatter
        XCTAssertTrue(val.formattedPrivateSale.hasPrefix("$"))
        XCTAssertTrue(val.formattedPrivateSale.contains("34"))
    }

    func testFormattedPrivateSaleWithCommas() {
        let val = Valuation(tradeIn: 25000, privateSale: 1234567, dealer: 37000, trend: ValuationTrend(amount: 0, direction: .up, summary: ""), lastUpdated: Date())
        XCTAssertTrue(val.formattedPrivateSale.contains(","))
    }

    // MARK: - Trend

    func testTrendDirectionUp() {
        let trend = ValuationTrend(amount: 800, direction: .up, summary: "Going up")
        XCTAssertEqual(trend.direction, .up)
        XCTAssertEqual(trend.direction.rawValue, "up")
    }

    func testTrendDirectionDown() {
        let trend = ValuationTrend(amount: 1200, direction: .down, summary: "Seasonal dip")
        XCTAssertEqual(trend.direction, .down)
        XCTAssertEqual(trend.direction.rawValue, "down")
    }

    func testTrendZeroAmount() {
        let trend = ValuationTrend(amount: 0, direction: .up, summary: "Flat")
        XCTAssertEqual(trend.amount, 0)
    }

    func testTrendNegativeAmount() {
        let trend = ValuationTrend(amount: -500, direction: .down, summary: "Loss")
        XCTAssertEqual(trend.amount, -500)
    }

    func testTrendLargeAmount() {
        let trend = ValuationTrend(amount: Int.max, direction: .up, summary: "Boom")
        XCTAssertEqual(trend.amount, Int.max)
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        let original = Valuation(
            tradeIn: 29000,
            privateSale: 34200,
            dealer: 37000,
            trend: ValuationTrend(amount: 800, direction: .up, summary: "Market up"),
            lastUpdated: Date(timeIntervalSince1970: 1_700_000_000)
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Valuation.self, from: data)

        XCTAssertEqual(decoded.tradeIn, original.tradeIn)
        XCTAssertEqual(decoded.privateSale, original.privateSale)
        XCTAssertEqual(decoded.dealer, original.dealer)
        XCTAssertEqual(decoded.trend.amount, original.trend.amount)
        XCTAssertEqual(decoded.trend.direction, original.trend.direction)
        XCTAssertEqual(decoded.trend.summary, original.trend.summary)
        XCTAssertEqual(decoded.lastUpdated, original.lastUpdated)
    }

    func testTrendCodableRoundTrip() throws {
        let original = ValuationTrend(amount: 1200, direction: .down, summary: "Seasonal decline")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ValuationTrend.self, from: data)

        XCTAssertEqual(decoded.amount, original.amount)
        XCTAssertEqual(decoded.direction, original.direction)
        XCTAssertEqual(decoded.summary, original.summary)
    }

    func testTrendDirectionCodable() throws {
        let up = ValuationTrend.TrendDirection.up
        let data = try JSONEncoder().encode(up)
        let decoded = try JSONDecoder().decode(ValuationTrend.TrendDirection.self, from: data)
        XCTAssertEqual(decoded, up)

        let down = ValuationTrend.TrendDirection.down
        let data2 = try JSONEncoder().encode(down)
        let decoded2 = try JSONDecoder().decode(ValuationTrend.TrendDirection.self, from: data2)
        XCTAssertEqual(decoded2, down)
    }

    // MARK: - Edge Cases

    func testZeroValues() {
        let val = Valuation(tradeIn: 0, privateSale: 0, dealer: 0, trend: ValuationTrend(amount: 0, direction: .up, summary: ""), lastUpdated: Date())
        XCTAssertEqual(val.tradeIn, 0)
        XCTAssertEqual(val.privateSale, 0)
        XCTAssertEqual(val.dealer, 0)
    }

    func testNegativeValues() {
        let val = Valuation(tradeIn: -1000, privateSale: -2000, dealer: -3000, trend: ValuationTrend(amount: -500, direction: .down, summary: "Crash"), lastUpdated: Date())
        XCTAssertEqual(val.tradeIn, -1000)
        XCTAssertEqual(val.privateSale, -2000)
        XCTAssertEqual(val.dealer, -3000)
    }

    func testVeryLargeValues() {
        let val = Valuation(tradeIn: 999_999_999, privateSale: 999_999_999, dealer: 999_999_999, trend: ValuationTrend(amount: 0, direction: .up, summary: ""), lastUpdated: Date())
        XCTAssertEqual(val.tradeIn, 999_999_999)
    }

    func testEmptySummary() {
        let trend = ValuationTrend(amount: 100, direction: .up, summary: "")
        XCTAssertEqual(trend.summary, "")
    }

    func testUnicodeInSummary() {
        let trend = ValuationTrend(amount: 100, direction: .up, summary: "\u{2191}\u{2191}\u{2191} Trending up!")
        XCTAssertTrue(trend.summary.contains("\u{2191}"))
    }

    func testMutability() {
        var val = Valuation(tradeIn: 10000, privateSale: 15000, dealer: 18000, trend: ValuationTrend(amount: 100, direction: .up, summary: "Up"), lastUpdated: Date())
        val.tradeIn = 20000
        val.privateSale = 25000
        val.dealer = 28000
        XCTAssertEqual(val.tradeIn, 20000)
        XCTAssertEqual(val.privateSale, 25000)
        XCTAssertEqual(val.dealer, 28000)
    }

    // MARK: - NumberFormatter Extension

    func testCurrencyFormatter() {
        let formatter = NumberFormatter.currency
        XCTAssertEqual(formatter.numberStyle, .decimal)
        XCTAssertEqual(formatter.groupingSeparator, ",")
    }

    func testCurrencyFormatterOutput() {
        let result = NumberFormatter.currency.string(from: NSNumber(value: 34200))
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.contains("34"))
    }

    func testCurrencyFormatterZero() {
        let result = NumberFormatter.currency.string(from: NSNumber(value: 0))
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "0")
    }

    func testCurrencyFormatterLargeNumber() {
        let result = NumberFormatter.currency.string(from: NSNumber(value: 1_234_567))
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.contains(","))
    }
}
