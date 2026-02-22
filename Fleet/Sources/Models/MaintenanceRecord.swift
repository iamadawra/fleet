import Foundation

struct MaintenanceRecord: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var provider: String
    var isCompleted: Bool
    var mileage: Int?

    var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, yyyy"
        return fmt.string(from: date)
    }

    var statusText: String {
        if isCompleted { return "Completed" }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM yyyy"
        return "Due · ~\(fmt.string(from: date))"
    }
}
