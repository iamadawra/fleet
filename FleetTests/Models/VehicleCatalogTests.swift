import XCTest
@testable import Fleet

final class VehicleCatalogTests: XCTestCase {

    // MARK: - Makes

    func testMakesIsNotEmpty() {
        XCTAssertFalse(VehicleCatalog.makes.isEmpty)
    }

    func testMakesAreSortedAlphabetically() {
        let makes = VehicleCatalog.makes
        XCTAssertEqual(makes, makes.sorted())
    }

    func testMakesContainsExpectedBrands() {
        let makes = VehicleCatalog.makes
        let expected = ["Toyota", "Honda", "Ford", "Tesla", "BMW", "Chevrolet"]
        for brand in expected {
            XCTAssertTrue(makes.contains(brand), "Expected \(brand) in makes")
        }
    }

    func testMakesHasNoDuplicates() {
        let makes = VehicleCatalog.makes
        XCTAssertEqual(makes.count, Set(makes).count, "Makes should have no duplicates")
    }

    // MARK: - Models

    func testModelsForKnownMake() {
        let models = VehicleCatalog.models(for: "Tesla")
        XCTAssertFalse(models.isEmpty)
        XCTAssertTrue(models.contains("Model 3"))
        XCTAssertTrue(models.contains("Model S"))
        XCTAssertTrue(models.contains("Model Y"))
    }

    func testModelsAreSortedAlphabetically() {
        let models = VehicleCatalog.models(for: "Toyota")
        XCTAssertEqual(models, models.sorted())
    }

    func testModelsForUnknownMake() {
        let models = VehicleCatalog.models(for: "NonExistentBrand")
        XCTAssertTrue(models.isEmpty)
    }

    func testModelsForEmptyString() {
        let models = VehicleCatalog.models(for: "")
        XCTAssertTrue(models.isEmpty)
    }

    func testModelsForCaseSensitivity() {
        let models = VehicleCatalog.models(for: "toyota")
        XCTAssertTrue(models.isEmpty, "Catalog lookup should be case-sensitive")
    }

    // MARK: - Years

    func testYearsIsNotEmpty() {
        XCTAssertFalse(VehicleCatalog.years.isEmpty)
    }

    func testYearsIsDescending() {
        let years = VehicleCatalog.years
        for i in 0..<(years.count - 1) {
            XCTAssertGreaterThan(years[i], years[i + 1], "Years should be in descending order")
        }
    }

    func testYearsRange() {
        let years = VehicleCatalog.years
        XCTAssertEqual(years.first, 2025, "Most recent year should be 2025")
        XCTAssertEqual(years.last, 2005, "Oldest year should be 2005")
    }

    func testYearsCount() {
        let years = VehicleCatalog.years
        XCTAssertEqual(years.count, 21, "Should have years from 2005 to 2025 inclusive")
    }

    func testYearsHasNoDuplicates() {
        let years = VehicleCatalog.years
        XCTAssertEqual(years.count, Set(years).count, "Years should have no duplicates")
    }

    // MARK: - Catalog Coverage

    func testToyotaHasExpectedModels() {
        let models = VehicleCatalog.models(for: "Toyota")
        let expected = ["Camry", "Corolla", "RAV4", "Highlander", "Tacoma", "Tundra"]
        for model in expected {
            XCTAssertTrue(models.contains(model), "Toyota should have \(model)")
        }
    }

    func testBMWHasExpectedModels() {
        let models = VehicleCatalog.models(for: "BMW")
        let expected = ["3 Series", "5 Series", "X5", "M4", "i4"]
        for model in expected {
            XCTAssertTrue(models.contains(model), "BMW should have \(model)")
        }
    }

    func testFordHasExpectedModels() {
        let models = VehicleCatalog.models(for: "Ford")
        let expected = ["F-150", "Mustang", "Explorer", "Bronco"]
        for model in expected {
            XCTAssertTrue(models.contains(model), "Ford should have \(model)")
        }
    }

    func testAllMakesHaveAtLeastOneModel() {
        for make in VehicleCatalog.makes {
            let models = VehicleCatalog.models(for: make)
            XCTAssertFalse(models.isEmpty, "\(make) should have at least one model")
        }
    }
}
