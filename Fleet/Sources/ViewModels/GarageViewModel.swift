import Foundation

@MainActor
class GarageViewModel: ObservableObject {
    @Published var vehicles: [Vehicle] = []
    @Published var upcomingEvents: [FleetEvent] = []
    @Published var selectedVehicle: Vehicle?

    var totalFleetValue: Int {
        vehicles.compactMap { $0.valuation?.privateSale }.reduce(0, +)
    }

    var formattedTotalFleetValue: String {
        "$\(NumberFormatter.currency.string(from: NSNumber(value: totalFleetValue)) ?? "\(totalFleetValue)")"
    }

    var alertCount: Int {
        vehicles.reduce(0) { count, vehicle in
            var alerts = 0
            if !vehicle.recalls.filter({ !$0.isResolved }).isEmpty { alerts += 1 }
            if vehicle.registration.isExpiringSoon { alerts += 1 }
            return count + alerts
        }
    }

    var openRecallCount: Int {
        vehicles.reduce(0) { $0 + $1.recalls.filter { !$0.isResolved }.count }
    }

    var expiringCount: Int {
        vehicles.filter { $0.registration.isExpiringSoon }.count
    }

    var fleetHealthScore: Int {
        let base = 100
        let recallPenalty = openRecallCount * 10
        let expiryPenalty = expiringCount * 4
        return max(0, base - recallPenalty - expiryPenalty)
    }

    func loadSampleData() {
        vehicles = SampleData.createSampleVehicles()
        upcomingEvents = SampleData.createUpcomingEvents()
    }
}
