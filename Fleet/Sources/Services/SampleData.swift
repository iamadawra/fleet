import Foundation
import SwiftData

enum SampleData {
    @MainActor
    static func seedIfEmpty(context: ModelContext) {
        let descriptor = FetchDescriptor<Vehicle>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        for vehicle in createSampleVehicles() {
            context.insert(vehicle)
        }
    }

    static func createSampleVehicles() -> [Vehicle] {
        let calendar = Calendar.current

        let tesla = Vehicle(
            id: UUID(),
            make: "Tesla",
            model: "Model 3",
            year: 2021,
            trim: "Long Range",
            color: "Pearl White",
            mileage: 28400,
            vin: "5YJ3E1EA1MF000001",
            imageURL: "tesla_model3",
            registration: RegistrationInfo(
                expiryDate: calendar.date(from: DateComponents(year: 2026, month: 3, day: 15))!,
                state: "CA"
            ),
            insurance: InsuranceInfo(
                provider: "State Farm",
                coverageType: "Full",
                expiryDate: calendar.date(from: DateComponents(year: 2026, month: 6, day: 30))!
            ),
            recalls: [
                Recall(
                    id: UUID(),
                    title: "FSD Safety",
                    description: "Full Self-Driving Beta software recall",
                    source: "NHTSA",
                    dateIssued: calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!,
                    isResolved: false
                )
            ],
            maintenanceRecords: [
                MaintenanceRecord(
                    id: UUID(),
                    title: "Annual Inspection",
                    date: calendar.date(from: DateComponents(year: 2025, month: 1, day: 8))!,
                    provider: "Tesla Service",
                    isCompleted: true,
                    mileage: 25000
                ),
                MaintenanceRecord(
                    id: UUID(),
                    title: "Tire Rotation",
                    date: calendar.date(from: DateComponents(year: 2024, month: 9, day: 14))!,
                    provider: "Discount Tire",
                    isCompleted: true,
                    mileage: 22000
                ),
                MaintenanceRecord(
                    id: UUID(),
                    title: "Tire Rotation",
                    date: calendar.date(from: DateComponents(year: 2025, month: 4, day: 1))!,
                    provider: "",
                    isCompleted: false,
                    mileage: 30000
                )
            ],
            valuation: Valuation(
                tradeIn: 29000,
                privateSale: 34200,
                dealer: 37000,
                trend: ValuationTrend(amount: 800, direction: .up, description: "Market trending ↑"),
                lastUpdated: Date()
            )
        )

        let bmw = Vehicle(
            id: UUID(),
            make: "BMW",
            model: "M4",
            year: 2022,
            trim: "Competition",
            color: "Isle of Man Blue",
            mileage: 18500,
            vin: "WBS43AZ02NCK00001",
            imageURL: "bmw_m4",
            registration: RegistrationInfo(
                expiryDate: calendar.date(from: DateComponents(year: 2026, month: 9, day: 20))!,
                state: "CA"
            ),
            insurance: InsuranceInfo(
                provider: "State Farm",
                coverageType: "Full",
                expiryDate: calendar.date(from: DateComponents(year: 2026, month: 6, day: 30))!
            ),
            recalls: [],
            maintenanceRecords: [
                MaintenanceRecord(
                    id: UUID(),
                    title: "Oil Change",
                    date: calendar.date(from: DateComponents(year: 2025, month: 2, day: 10))!,
                    provider: "BMW Dealer",
                    isCompleted: true,
                    mileage: 15000
                ),
                MaintenanceRecord(
                    id: UUID(),
                    title: "Brake Fluid Change",
                    date: calendar.date(from: DateComponents(year: 2026, month: 7, day: 15))!,
                    provider: "",
                    isCompleted: false,
                    mileage: 45000
                )
            ],
            valuation: Valuation(
                tradeIn: 60000,
                privateSale: 68500,
                dealer: 72000,
                trend: ValuationTrend(amount: 1200, direction: .down, description: "Seasonal dip"),
                lastUpdated: Date()
            )
        )

        let jeep = Vehicle(
            id: UUID(),
            make: "Jeep",
            model: "Wrangler",
            year: 2020,
            trim: "Rubicon",
            color: "Sarge Green",
            mileage: 42000,
            vin: "1C4HJXFG5LW000001",
            imageURL: "jeep_wrangler",
            registration: RegistrationInfo(
                expiryDate: calendar.date(from: DateComponents(year: 2026, month: 3, day: 15))!,
                state: "CA"
            ),
            insurance: InsuranceInfo(
                provider: "Geico",
                coverageType: "Full",
                expiryDate: calendar.date(from: DateComponents(year: 2026, month: 8, day: 15))!
            ),
            recalls: [],
            maintenanceRecords: [
                MaintenanceRecord(
                    id: UUID(),
                    title: "Oil Change",
                    date: calendar.date(from: DateComponents(year: 2025, month: 3, day: 20))!,
                    provider: "Jiffy Lube",
                    isCompleted: true,
                    mileage: 40000
                )
            ],
            valuation: Valuation(
                tradeIn: 28000,
                privateSale: 32000,
                dealer: 35000,
                trend: ValuationTrend(amount: 500, direction: .up, description: "Steady demand"),
                lastUpdated: Date()
            )
        )

        return [tesla, bmw, jeep]
    }
}
