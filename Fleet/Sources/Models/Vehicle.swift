import Foundation

struct Vehicle: Identifiable, Codable, Hashable {
    static func == (lhs: Vehicle, rhs: Vehicle) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    let id: UUID
    var make: String
    var model: String
    var year: Int
    var trim: String
    var color: String
    var mileage: Int
    var vin: String
    var imageURL: String
    var registration: RegistrationInfo
    var insurance: InsuranceInfo
    var recalls: [Recall]
    var maintenanceRecords: [MaintenanceRecord]
    var valuation: Valuation?

    var displayName: String { "\(make) \(model)" }
    var subtitle: String { "\(year) · \(trim) · \(color)" }

    var healthStatus: HealthStatus {
        if !recalls.filter({ !$0.isResolved }).isEmpty { return .urgent }
        if registration.daysUntilExpiry < 30 { return .warning }
        return .good
    }

    var healthBadgeText: String {
        switch healthStatus {
        case .urgent:
            let count = recalls.filter { !$0.isResolved }.count
            return "⚠ \(count) Recall\(count > 1 ? "s" : "")"
        case .warning:
            return "⏰ Reg in \(registration.daysUntilExpiry)d"
        case .good:
            return "● All Good"
        }
    }
}

enum HealthStatus {
    case good, warning, urgent
}
