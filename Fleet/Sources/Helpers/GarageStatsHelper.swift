import Foundation

enum GarageStatsHelper {

    static func totalFleetValue(_ vehicles: [Vehicle]) -> Int {
        vehicles.compactMap { $0.valuation?.privateSale }.reduce(0, +)
    }

    static func formattedTotalFleetValue(_ vehicles: [Vehicle]) -> String {
        let total = totalFleetValue(vehicles)
        return "$\(NumberFormatter.currency.string(from: NSNumber(value: total)) ?? "\(total)")"
    }

    static func alertCount(_ vehicles: [Vehicle]) -> Int {
        vehicles.reduce(0) { count, vehicle in
            var alerts = 0
            if !vehicle.recalls.filter({ !$0.isResolved }).isEmpty { alerts += 1 }
            if vehicle.registration.isExpiringSoon { alerts += 1 }
            return count + alerts
        }
    }

    static func fleetHealthScore(_ vehicles: [Vehicle]) -> Int {
        let base = 100
        let recallPenalty = openRecallCount(vehicles) * 10
        let expiryPenalty = expiringCount(vehicles) * 4
        return max(0, base - recallPenalty - expiryPenalty)
    }

    static func openRecallCount(_ vehicles: [Vehicle]) -> Int {
        vehicles.reduce(0) { $0 + $1.recalls.filter { !$0.isResolved }.count }
    }

    static func expiringCount(_ vehicles: [Vehicle]) -> Int {
        vehicles.filter { $0.registration.isExpiringSoon }.count
    }

    static func upcomingEvents(_ vehicles: [Vehicle]) -> [FleetEvent] {
        var events: [FleetEvent] = []

        for vehicle in vehicles {
            let label = "\(vehicle.make) \(vehicle.model)"

            // Registration expiry
            if vehicle.registration.daysUntilExpiry > 0 && vehicle.registration.daysUntilExpiry < 180 {
                events.append(FleetEvent(
                    title: "Registration Renewal",
                    vehicleName: "\(label) · \(vehicle.year)",
                    date: vehicle.registration.expiryDate,
                    category: .registration,
                    vehicleId: vehicle.id
                ))
            }

            // Insurance expiry
            if vehicle.insurance.daysUntilExpiry > 0 && vehicle.insurance.daysUntilExpiry < 180 {
                events.append(FleetEvent(
                    title: "Insurance Renewal",
                    vehicleName: "\(label) · \(vehicle.insurance.provider)",
                    date: vehicle.insurance.expiryDate,
                    category: .insurance,
                    vehicleId: vehicle.id
                ))
            }

            // Open recalls
            for recall in vehicle.recalls where !recall.isResolved {
                events.append(FleetEvent(
                    title: recall.title,
                    vehicleName: "\(label) · \(recall.source)",
                    date: recall.dateIssued,
                    category: .recall,
                    vehicleId: vehicle.id
                ))
            }

            // Upcoming maintenance
            for record in vehicle.maintenanceRecords where !record.isCompleted {
                let mileageStr = record.mileage.map { "\(NumberFormatter.currency.string(from: NSNumber(value: $0)) ?? "\($0)") mi" } ?? ""
                events.append(FleetEvent(
                    title: record.title,
                    vehicleName: "\(label) · \(mileageStr)",
                    date: record.date,
                    category: .maintenance,
                    vehicleId: vehicle.id
                ))
            }
        }

        return events.sorted { $0.date < $1.date }
    }
}
