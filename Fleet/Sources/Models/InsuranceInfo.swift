import Foundation

struct InsuranceInfo: Codable {
    var provider: String
    var coverageType: String
    var expiryDate: Date

    var daysUntilExpiry: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
    }

    var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, yyyy"
        return fmt.string(from: expiryDate)
    }

    var statusText: String {
        "\(provider) · \(coverageType)"
    }

    var isActive: Bool { daysUntilExpiry > 0 }
}
