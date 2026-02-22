import XCTest
@testable import Fleet

final class SampleDataTests: XCTestCase {

    // MARK: - Sample Vehicle Generation

    func testCreateSampleVehiclesCount() {
        let vehicles = SampleData.createSampleVehicles()
        XCTAssertEqual(vehicles.count, 3)
    }

    func testSampleVehicleMakes() {
        let vehicles = SampleData.createSampleVehicles()
        let makes = vehicles.map { $0.make }
        XCTAssertTrue(makes.contains("Tesla"))
        XCTAssertTrue(makes.contains("BMW"))
        XCTAssertTrue(makes.contains("Jeep"))
    }

    func testSampleVehicleModels() {
        let vehicles = SampleData.createSampleVehicles()
        let models = vehicles.map { $0.model }
        XCTAssertTrue(models.contains("Model 3"))
        XCTAssertTrue(models.contains("M4"))
        XCTAssertTrue(models.contains("Wrangler"))
    }

    func testSampleVehicleUniqueIDs() {
        let vehicles = SampleData.createSampleVehicles()
        let ids = Set(vehicles.map { $0.id })
        XCTAssertEqual(ids.count, 3, "All sample vehicles should have unique IDs")
    }

    func testSampleVehicleIDsChangeBetweenCalls() {
        let vehicles1 = SampleData.createSampleVehicles()
        let vehicles2 = SampleData.createSampleVehicles()
        // IDs are generated fresh each call
        XCTAssertNotEqual(vehicles1[0].id, vehicles2[0].id)
    }

    // MARK: - Tesla Sample Data

    func testTeslaSampleData() {
        let vehicles = SampleData.createSampleVehicles()
        let tesla = vehicles.first { $0.make == "Tesla" }!

        XCTAssertEqual(tesla.model, "Model 3")
        XCTAssertEqual(tesla.year, 2021)
        XCTAssertEqual(tesla.trim, "Long Range")
        XCTAssertEqual(tesla.color, "Pearl White")
        XCTAssertEqual(tesla.mileage, 28400)
        XCTAssertEqual(tesla.vin, "5YJ3E1EA1MF000001")
        XCTAssertEqual(tesla.imageURL, "tesla_model3")
    }

    func testTeslaRecalls() {
        let vehicles = SampleData.createSampleVehicles()
        let tesla = vehicles.first { $0.make == "Tesla" }!

        XCTAssertEqual(tesla.recalls.count, 1)
        XCTAssertEqual(tesla.recalls.first?.title, "FSD Safety")
        XCTAssertFalse(tesla.recalls.first?.isResolved ?? true)
        XCTAssertEqual(tesla.recalls.first?.source, "NHTSA")
    }

    func testTeslaMaintenanceRecords() {
        let vehicles = SampleData.createSampleVehicles()
        let tesla = vehicles.first { $0.make == "Tesla" }!

        XCTAssertEqual(tesla.maintenanceRecords.count, 3)
        let completed = tesla.maintenanceRecords.filter { $0.isCompleted }
        let upcoming = tesla.maintenanceRecords.filter { !$0.isCompleted }
        XCTAssertEqual(completed.count, 2)
        XCTAssertEqual(upcoming.count, 1)
    }

    func testTeslaValuation() {
        let vehicles = SampleData.createSampleVehicles()
        let tesla = vehicles.first { $0.make == "Tesla" }!

        XCTAssertNotNil(tesla.valuation)
        XCTAssertEqual(tesla.valuation?.tradeIn, 29000)
        XCTAssertEqual(tesla.valuation?.privateSale, 34200)
        XCTAssertEqual(tesla.valuation?.dealer, 37000)
        XCTAssertEqual(tesla.valuation?.trend.direction, .up)
    }

    func testTeslaRegistration() {
        let vehicles = SampleData.createSampleVehicles()
        let tesla = vehicles.first { $0.make == "Tesla" }!

        XCTAssertEqual(tesla.registration.state, "CA")
    }

    func testTeslaInsurance() {
        let vehicles = SampleData.createSampleVehicles()
        let tesla = vehicles.first { $0.make == "Tesla" }!

        XCTAssertEqual(tesla.insurance.provider, "State Farm")
        XCTAssertEqual(tesla.insurance.coverageType, "Full")
    }

    // MARK: - BMW Sample Data

    func testBMWSampleData() {
        let vehicles = SampleData.createSampleVehicles()
        let bmw = vehicles.first { $0.make == "BMW" }!

        XCTAssertEqual(bmw.model, "M4")
        XCTAssertEqual(bmw.year, 2022)
        XCTAssertEqual(bmw.trim, "Competition")
        XCTAssertEqual(bmw.mileage, 18500)
        XCTAssertTrue(bmw.recalls.isEmpty)
    }

    func testBMWMaintenanceRecords() {
        let vehicles = SampleData.createSampleVehicles()
        let bmw = vehicles.first { $0.make == "BMW" }!

        XCTAssertEqual(bmw.maintenanceRecords.count, 2)
    }

    func testBMWValuation() {
        let vehicles = SampleData.createSampleVehicles()
        let bmw = vehicles.first { $0.make == "BMW" }!

        XCTAssertNotNil(bmw.valuation)
        XCTAssertEqual(bmw.valuation?.trend.direction, .down)
    }

    // MARK: - Jeep Sample Data

    func testJeepSampleData() {
        let vehicles = SampleData.createSampleVehicles()
        let jeep = vehicles.first { $0.make == "Jeep" }!

        XCTAssertEqual(jeep.model, "Wrangler")
        XCTAssertEqual(jeep.year, 2020)
        XCTAssertEqual(jeep.trim, "Rubicon")
        XCTAssertEqual(jeep.mileage, 42000)
        XCTAssertTrue(jeep.recalls.isEmpty)
    }

    func testJeepMaintenanceRecords() {
        let vehicles = SampleData.createSampleVehicles()
        let jeep = vehicles.first { $0.make == "Jeep" }!

        XCTAssertEqual(jeep.maintenanceRecords.count, 1)
        XCTAssertTrue(jeep.maintenanceRecords.first?.isCompleted ?? false)
    }

    func testJeepInsurance() {
        let vehicles = SampleData.createSampleVehicles()
        let jeep = vehicles.first { $0.make == "Jeep" }!

        XCTAssertEqual(jeep.insurance.provider, "Geico")
    }

    // MARK: - All Vehicles Have Valuations

    func testAllSampleVehiclesHaveValuations() {
        let vehicles = SampleData.createSampleVehicles()
        for vehicle in vehicles {
            XCTAssertNotNil(vehicle.valuation, "\(vehicle.make) should have a valuation")
        }
    }

    // MARK: - All Vehicles Have Registration Info

    func testAllSampleVehiclesHaveRegistration() {
        let vehicles = SampleData.createSampleVehicles()
        for vehicle in vehicles {
            XCTAssertFalse(vehicle.registration.state.isEmpty, "\(vehicle.make) should have a registration state")
        }
    }

    // MARK: - All Vehicles Have Insurance

    func testAllSampleVehiclesHaveInsurance() {
        let vehicles = SampleData.createSampleVehicles()
        for vehicle in vehicles {
            XCTAssertFalse(vehicle.insurance.provider.isEmpty, "\(vehicle.make) should have an insurance provider")
        }
    }
}
