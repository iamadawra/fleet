import Foundation
import SwiftData

@Model
final class Vehicle {
    @Attribute(.unique) var id: UUID
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

    init(
        id: UUID = UUID(),
        make: String,
        model: String,
        year: Int,
        trim: String = "",
        color: String = "",
        mileage: Int = 0,
        vin: String = "",
        imageURL: String = "",
        registration: RegistrationInfo = RegistrationInfo(expiryDate: Date(), state: ""),
        insurance: InsuranceInfo = InsuranceInfo(provider: "", coverageType: "", expiryDate: Date()),
        recalls: [Recall] = [],
        maintenanceRecords: [MaintenanceRecord] = [],
        valuation: Valuation? = nil
    ) {
        self.id = id
        self.make = make
        self.model = model
        self.year = year
        self.trim = trim
        self.color = color
        self.mileage = mileage
        self.vin = vin
        self.imageURL = imageURL
        self.registration = registration
        self.insurance = insurance
        self.recalls = recalls
        self.maintenanceRecords = maintenanceRecords
        self.valuation = valuation
    }

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

extension Vehicle: Hashable {
    static func == (lhs: Vehicle, rhs: Vehicle) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum HealthStatus {
    case good, warning, urgent
}
