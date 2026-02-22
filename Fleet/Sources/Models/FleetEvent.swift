import Foundation

struct FleetEvent: Identifiable {
    let id = UUID()
    var title: String
    var vehicleName: String
    var date: Date
    var category: EventCategory

    var day: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "dd"
        return fmt.string(from: date)
    }

    var month: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM"
        return fmt.string(from: date)
    }

    enum EventCategory: String {
        case registration, insurance, maintenance, recall
    }
}
