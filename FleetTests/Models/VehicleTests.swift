import XCTest
import SwiftData
@testable import Fleet

final class VehicleTests: XCTestCase {

    // MARK: - Initialization

    func testDefaultInitialization() {
        let vehicle = Vehicle(make: "Toyota", model: "Camry", year: 2023)
        XCTAssertEqual(vehicle.make, "Toyota")
        XCTAssertEqual(vehicle.model, "Camry")
        XCTAssertEqual(vehicle.year, 2023)
        XCTAssertEqual(vehicle.trim, "")
        XCTAssertEqual(vehicle.color, "")
        XCTAssertEqual(vehicle.mileage, 0)
        XCTAssertEqual(vehicle.vin, "")
        XCTAssertEqual(vehicle.imageURL, "")
        XCTAssertTrue(vehicle.recalls.isEmpty)
        XCTAssertTrue(vehicle.maintenanceRecords.isEmpty)
        XCTAssertNil(vehicle.valuation)
    }

    func testFullInitialization() {
        let id = UUID()
        let regDate = Date(timeIntervalSince1970: 2_000_000_000)
        let insDate = Date(timeIntervalSince1970: 2_000_000_000)
        let reg = RegistrationInfo(expiryDate: regDate, state: "NY")
        let ins = InsuranceInfo(provider: "Allstate", coverageType: "Comprehensive", expiryDate: insDate)
        let recall = Recall(id: UUID(), title: "Brake Issue", details: "Pads", source: "NHTSA", dateIssued: Date(), isResolved: false)
        let maint = MaintenanceRecord(id: UUID(), title: "Oil Change", date: Date(), provider: "Shop", isCompleted: true, mileage: 5000)
        let val = Valuation(tradeIn: 20000, privateSale: 25000, dealer: 28000, trend: ValuationTrend(amount: 500, direction: .up, summary: "Up"), lastUpdated: Date())

        let vehicle = Vehicle(
            id: id,
            make: "Honda",
            model: "Civic",
            year: 2024,
            trim: "Sport",
            color: "Red",
            mileage: 15000,
            vin: "1HGBH41JXMN109186",
            imageURL: "civic_image",
            registration: reg,
            insurance: ins,
            recalls: [recall],
            maintenanceRecords: [maint],
            valuation: val
        )

        XCTAssertEqual(vehicle.id, id)
        XCTAssertEqual(vehicle.make, "Honda")
        XCTAssertEqual(vehicle.model, "Civic")
        XCTAssertEqual(vehicle.year, 2024)
        XCTAssertEqual(vehicle.trim, "Sport")
        XCTAssertEqual(vehicle.color, "Red")
        XCTAssertEqual(vehicle.mileage, 15000)
        XCTAssertEqual(vehicle.vin, "1HGBH41JXMN109186")
        XCTAssertEqual(vehicle.imageURL, "civic_image")
        XCTAssertEqual(vehicle.registration.state, "NY")
        XCTAssertEqual(vehicle.insurance.provider, "Allstate")
        XCTAssertEqual(vehicle.recalls.count, 1)
        XCTAssertEqual(vehicle.maintenanceRecords.count, 1)
        XCTAssertNotNil(vehicle.valuation)
    }

    // MARK: - UUID Uniqueness

    func testUUIDUniqueness() {
        let v1 = Vehicle(make: "Ford", model: "F150", year: 2023)
        let v2 = Vehicle(make: "Ford", model: "F150", year: 2023)
        XCTAssertNotEqual(v1.id, v2.id)
    }

    func testCustomUUID() {
        let customId = UUID()
        let vehicle = Vehicle(id: customId, make: "Ford", model: "F150", year: 2023)
        XCTAssertEqual(vehicle.id, customId)
    }

    // MARK: - Computed Properties

    func testDisplayName() {
        let vehicle = Vehicle(make: "Tesla", model: "Model 3", year: 2021)
        XCTAssertEqual(vehicle.displayName, "Tesla Model 3")
    }

    func testDisplayNameWithEmptyMake() {
        let vehicle = Vehicle(make: "", model: "Model 3", year: 2021)
        XCTAssertEqual(vehicle.displayName, " Model 3")
    }

    func testDisplayNameWithEmptyModel() {
        let vehicle = Vehicle(make: "Tesla", model: "", year: 2021)
        XCTAssertEqual(vehicle.displayName, "Tesla ")
    }

    func testSubtitle() {
        let vehicle = Vehicle(make: "BMW", model: "M4", year: 2022, trim: "Competition", color: "Blue")
        XCTAssertEqual(vehicle.subtitle, "2022 \u{00B7} Competition \u{00B7} Blue")
    }

    func testSubtitleWithEmptyFields() {
        let vehicle = Vehicle(make: "BMW", model: "M4", year: 2022)
        XCTAssertEqual(vehicle.subtitle, "2022 \u{00B7}  \u{00B7} ")
    }

    // MARK: - Health Status

    func testHealthStatusGood() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 60, to: Date())!
        let vehicle = Vehicle(
            make: "Honda", model: "Accord", year: 2023,
            registration: RegistrationInfo(expiryDate: futureDate, state: "CA"),
            recalls: []
        )
        XCTAssertEqual(vehicle.healthStatus, .good)
    }

    func testHealthStatusUrgentWithUnresolvedRecall() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 60, to: Date())!
        let recall = Recall(id: UUID(), title: "Airbag", details: "Defect", source: "NHTSA", dateIssued: Date(), isResolved: false)
        let vehicle = Vehicle(
            make: "Honda", model: "Accord", year: 2023,
            registration: RegistrationInfo(expiryDate: futureDate, state: "CA"),
            recalls: [recall]
        )
        XCTAssertEqual(vehicle.healthStatus, .urgent)
    }

    func testHealthStatusGoodWithResolvedRecall() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 60, to: Date())!
        let recall = Recall(id: UUID(), title: "Airbag", details: "Defect", source: "NHTSA", dateIssued: Date(), isResolved: true)
        let vehicle = Vehicle(
            make: "Honda", model: "Accord", year: 2023,
            registration: RegistrationInfo(expiryDate: futureDate, state: "CA"),
            recalls: [recall]
        )
        XCTAssertEqual(vehicle.healthStatus, .good)
    }

    func testHealthStatusWarningRegistrationExpiringSoon() {
        let soonDate = Calendar.current.date(byAdding: .day, value: 15, to: Date())!
        let vehicle = Vehicle(
            make: "Honda", model: "Accord", year: 2023,
            registration: RegistrationInfo(expiryDate: soonDate, state: "CA"),
            recalls: []
        )
        XCTAssertEqual(vehicle.healthStatus, .warning)
    }

    func testHealthStatusUrgentTakesPrecedenceOverWarning() {
        let soonDate = Calendar.current.date(byAdding: .day, value: 15, to: Date())!
        let recall = Recall(id: UUID(), title: "Engine", details: "Issue", source: "NHTSA", dateIssued: Date(), isResolved: false)
        let vehicle = Vehicle(
            make: "Honda", model: "Accord", year: 2023,
            registration: RegistrationInfo(expiryDate: soonDate, state: "CA"),
            recalls: [recall]
        )
        XCTAssertEqual(vehicle.healthStatus, .urgent)
    }

    func testHealthStatusMultipleUnresolvedRecalls() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 60, to: Date())!
        let recalls = [
            Recall(id: UUID(), title: "R1", details: "", source: "", dateIssued: Date(), isResolved: false),
            Recall(id: UUID(), title: "R2", details: "", source: "", dateIssued: Date(), isResolved: false),
            Recall(id: UUID(), title: "R3", details: "", source: "", dateIssued: Date(), isResolved: true)
        ]
        let vehicle = Vehicle(
            make: "Honda", model: "Accord", year: 2023,
            registration: RegistrationInfo(expiryDate: futureDate, state: "CA"),
            recalls: recalls
        )
        XCTAssertEqual(vehicle.healthStatus, .urgent)
    }

    // MARK: - Health Badge Text

    func testHealthBadgeTextGood() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 60, to: Date())!
        let vehicle = Vehicle(
            make: "Honda", model: "Accord", year: 2023,
            registration: RegistrationInfo(expiryDate: futureDate, state: "CA")
        )
        XCTAssertEqual(vehicle.healthBadgeText, "\u{25CF} All Good")
    }

    func testHealthBadgeTextSingleRecall() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 60, to: Date())!
        let recall = Recall(id: UUID(), title: "Brake", details: "", source: "", dateIssued: Date(), isResolved: false)
        let vehicle = Vehicle(
            make: "Honda", model: "Accord", year: 2023,
            registration: RegistrationInfo(expiryDate: futureDate, state: "CA"),
            recalls: [recall]
        )
        XCTAssertTrue(vehicle.healthBadgeText.contains("1 Recall"))
        XCTAssertFalse(vehicle.healthBadgeText.contains("Recalls"))
    }

    func testHealthBadgeTextMultipleRecalls() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 60, to: Date())!
        let recalls = [
            Recall(id: UUID(), title: "R1", details: "", source: "", dateIssued: Date(), isResolved: false),
            Recall(id: UUID(), title: "R2", details: "", source: "", dateIssued: Date(), isResolved: false)
        ]
        let vehicle = Vehicle(
            make: "Honda", model: "Accord", year: 2023,
            registration: RegistrationInfo(expiryDate: futureDate, state: "CA"),
            recalls: recalls
        )
        XCTAssertTrue(vehicle.healthBadgeText.contains("2 Recalls"))
    }

    func testHealthBadgeTextWarning() {
        let soonDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        let vehicle = Vehicle(
            make: "Honda", model: "Accord", year: 2023,
            registration: RegistrationInfo(expiryDate: soonDate, state: "CA")
        )
        XCTAssertTrue(vehicle.healthBadgeText.contains("Reg in"))
        XCTAssertTrue(vehicle.healthBadgeText.contains("d"))
    }

    // MARK: - Edge Cases

    func testEmptyStrings() {
        let vehicle = Vehicle(make: "", model: "", year: 0, trim: "", color: "", mileage: 0, vin: "", imageURL: "")
        XCTAssertEqual(vehicle.make, "")
        XCTAssertEqual(vehicle.model, "")
        XCTAssertEqual(vehicle.year, 0)
        XCTAssertEqual(vehicle.displayName, " ")
    }

    func testNegativeMileage() {
        let vehicle = Vehicle(make: "Ford", model: "Focus", year: 2020, mileage: -100)
        XCTAssertEqual(vehicle.mileage, -100)
    }

    func testNegativeYear() {
        let vehicle = Vehicle(make: "Ford", model: "Focus", year: -1)
        XCTAssertEqual(vehicle.year, -1)
    }

    func testYearZero() {
        let vehicle = Vehicle(make: "Ford", model: "Focus", year: 0)
        XCTAssertEqual(vehicle.year, 0)
    }

    func testVeryLargeYear() {
        let vehicle = Vehicle(make: "Ford", model: "Focus", year: 999999)
        XCTAssertEqual(vehicle.year, 999999)
    }

    func testVeryLargeMileage() {
        let vehicle = Vehicle(make: "Ford", model: "Focus", year: 2020, mileage: Int.max)
        XCTAssertEqual(vehicle.mileage, Int.max)
    }

    func testUnicodeCharactersInMake() {
        let vehicle = Vehicle(make: "\u{1F697}", model: "Car", year: 2023)
        XCTAssertEqual(vehicle.make, "\u{1F697}")
        XCTAssertEqual(vehicle.displayName, "\u{1F697} Car")
    }

    func testCJKCharacters() {
        let vehicle = Vehicle(make: "\u{8C50}\u{7530}", model: "\u{30AB}\u{30E0}\u{30EA}", year: 2023)
        XCTAssertEqual(vehicle.make, "\u{8C50}\u{7530}")
        XCTAssertEqual(vehicle.model, "\u{30AB}\u{30E0}\u{30EA}")
    }

    func testArabicCharacters() {
        let vehicle = Vehicle(make: "\u{0633}\u{064A}\u{0627}\u{0631}\u{0629}", model: "Test", year: 2023)
        XCTAssertEqual(vehicle.make, "\u{0633}\u{064A}\u{0627}\u{0631}\u{0629}")
    }

    func testVeryLongStrings() {
        let longString = String(repeating: "a", count: 10_000)
        let vehicle = Vehicle(make: longString, model: longString, year: 2023, trim: longString, color: longString, vin: longString)
        XCTAssertEqual(vehicle.make.count, 10_000)
        XCTAssertEqual(vehicle.model.count, 10_000)
        XCTAssertEqual(vehicle.trim.count, 10_000)
    }

    func testSpecialCharactersInVIN() {
        let vin = "ABC-123!@#$%^&*()"
        let vehicle = Vehicle(make: "Test", model: "Car", year: 2023, vin: vin)
        XCTAssertEqual(vehicle.vin, vin)
    }

    // MARK: - Hashable / Equatable

    func testEquality() {
        let id = UUID()
        let v1 = Vehicle(id: id, make: "A", model: "B", year: 2023)
        let v2 = Vehicle(id: id, make: "C", model: "D", year: 2024)
        XCTAssertEqual(v1, v2, "Vehicles with same ID should be equal regardless of other fields")
    }

    func testInequality() {
        let v1 = Vehicle(make: "A", model: "B", year: 2023)
        let v2 = Vehicle(make: "A", model: "B", year: 2023)
        XCTAssertNotEqual(v1, v2, "Vehicles with different IDs should not be equal")
    }

    func testHashable() {
        let id = UUID()
        let v1 = Vehicle(id: id, make: "A", model: "B", year: 2023)
        let v2 = Vehicle(id: id, make: "C", model: "D", year: 2024)
        var set = Set<Vehicle>()
        set.insert(v1)
        set.insert(v2)
        XCTAssertEqual(set.count, 1, "Vehicles with same ID should hash to same bucket")
    }

    // MARK: - HealthStatus Enum

    func testHealthStatusValues() {
        XCTAssertNotNil(HealthStatus.good)
        XCTAssertNotNil(HealthStatus.warning)
        XCTAssertNotNil(HealthStatus.urgent)
    }
}
