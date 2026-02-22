import Foundation

struct RegistrationInfo: Codable {
    var expiryDate: Date
    var state: String

    var daysUntilExpiry: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
    }

    var isExpiringSoon: Bool { daysUntilExpiry < 30 && daysUntilExpiry > 0 }
    var isExpired: Bool { daysUntilExpiry <= 0 }

    var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, yyyy"
        return fmt.string(from: expiryDate)
    }

    var statusText: String {
        if isExpired { return "Expired" }
        if isExpiringSoon { return "Expires in \(daysUntilExpiry) days" }
        return "Active"
    }
}
