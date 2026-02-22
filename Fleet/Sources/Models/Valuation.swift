import Foundation

struct Valuation: Codable {
    var tradeIn: Int
    var privateSale: Int
    var dealer: Int
    var trend: ValuationTrend
    var lastUpdated: Date

    var formattedPrivateSale: String {
        "$\(NumberFormatter.currency.string(from: NSNumber(value: privateSale)) ?? "\(privateSale)")"
    }

    var formattedTradeIn: String { "$\(tradeIn / 1000)k" }
    var formattedDealer: String { "$\(dealer / 1000)k" }
}

struct ValuationTrend: Codable {
    var amount: Int
    var direction: TrendDirection
    var summary: String

    enum TrendDirection: String, Codable {
        case up, down
    }
}

extension NumberFormatter {
    static let currency: NumberFormatter = {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.groupingSeparator = ","
        return fmt
    }()
}
