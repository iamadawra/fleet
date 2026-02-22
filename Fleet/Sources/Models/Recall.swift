import Foundation

struct Recall: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var source: String
    var dateIssued: Date
    var isResolved: Bool

    var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, yyyy"
        return fmt.string(from: dateIssued)
    }
}
