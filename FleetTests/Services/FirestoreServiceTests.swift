import XCTest
import FirebaseFirestore
@testable import Fleet

/// Tests for FirestoreService data conversion logic (dictToVehicle / vehicleToDict).
/// These tests focus on the pure data transformation without requiring a live Firebase connection.
@MainActor
final class FirestoreServiceTests: XCTestCase {

    var service: FirestoreService!

    override func setUp() {
        super.setUp()
        service = FirestoreService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeTimestamp(_ date: Date = Date()) -> Timestamp {
        Timestamp(date: date)
    }

    private func makeValidVehicleDict(
        make: String = "Toyota",
        model: String = "Camry",
        year: Int = 2023,
        trim: String = "SE",
        color: String = "Silver",
        mileage: Int = 25000,
        vin: String = "1HGBH41JXMN109186",
        imageURL: String = "camry_image",
        registration: [String: Any]? = nil,
        insurance: [String: Any]? = nil,
        recalls: [[String: Any]]? = nil,
        maintenanceRecords: [[String: Any]]? = nil,
        valuation: [String: Any]? = nil
    ) -> [String: Any] {
        var dict: [String: Any] = [
            "make": make,
            "model": model,
            "year": year,
            "trim": trim,
            "color": color,
            "mileage": mileage,
            "vin": vin,
            "imageURL": imageURL
        ]

        dict["registration"] = registration ?? [
            "expiryDate": makeTimestamp(),
            "state": "CA"
        ]

        dict["insurance"] = insurance ?? [
            "provider": "State Farm",
            "coverageType": "Full",
            "expiryDate": makeTimestamp()
        ]

        if let recalls = recalls {
            dict["recalls"] = recalls
        } else {
            dict["recalls"] = [] as [[String: Any]]
        }

        if let maintenanceRecords = maintenanceRecords {
            dict["maintenanceRecords"] = maintenanceRecords
        } else {
            dict["maintenanceRecords"] = [] as [[String: Any]]
        }

        if let valuation = valuation {
            dict["valuation"] = valuation
        }

        return dict
    }

    private func makeValidRecallDict(
        id: UUID = UUID(),
        title: String = "Brake Recall",
        description: String = "Brake pad defect",
        source: String = "NHTSA",
        dateIssued: Date = Date(),
        isResolved: Bool = false
    ) -> [String: Any] {
        [
            "id": id.uuidString,
            "title": title,
            "description": description,
            "source": source,
            "dateIssued": makeTimestamp(dateIssued),
            "isResolved": isResolved
        ]
    }

    private func makeValidMaintenanceDict(
        id: UUID = UUID(),
        title: String = "Oil Change",
        date: Date = Date(),
        provider: String = "Dealer",
        isCompleted: Bool = true,
        mileage: Int? = 5000
    ) -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "title": title,
            "date": makeTimestamp(date),
            "provider": provider,
            "isCompleted": isCompleted
        ]
        if let mileage = mileage {
            dict["mileage"] = mileage
        }
        return dict
    }

    private func makeValidValuationDict(
        tradeIn: Int = 25000,
        privateSale: Int = 30000,
        dealer: Int = 33000,
        trendAmount: Int = 500,
        trendDirection: String = "up",
        trendDescription: String = "Market up",
        lastUpdated: Date = Date()
    ) -> [String: Any] {
        [
            "tradeIn": tradeIn,
            "privateSale": privateSale,
            "dealer": dealer,
            "trend": [
                "amount": trendAmount,
                "direction": trendDirection,
                "description": trendDescription
            ] as [String: Any],
            "lastUpdated": makeTimestamp(lastUpdated)
        ]
    }

    // MARK: - dictToVehicle: Valid Complete Data

    func testDictToVehicleWithCompleteData() {
        let docId = UUID().uuidString
        let recallId = UUID()
        let maintId = UUID()

        let dict = makeValidVehicleDict(
            recalls: [makeValidRecallDict(id: recallId, title: "Airbag")],
            maintenanceRecords: [makeValidMaintenanceDict(id: maintId, title: "Tire Rotation", mileage: 30000)],
            valuation: makeValidValuationDict(tradeIn: 20000, privateSale: 25000, dealer: 28000)
        )

        let vehicle = service.dictToVehicle(dict, docId: docId)

        XCTAssertNotNil(vehicle)
        XCTAssertEqual(vehicle?.id.uuidString, docId)
        XCTAssertEqual(vehicle?.make, "Toyota")
        XCTAssertEqual(vehicle?.model, "Camry")
        XCTAssertEqual(vehicle?.year, 2023)
        XCTAssertEqual(vehicle?.trim, "SE")
        XCTAssertEqual(vehicle?.color, "Silver")
        XCTAssertEqual(vehicle?.mileage, 25000)
        XCTAssertEqual(vehicle?.vin, "1HGBH41JXMN109186")
        XCTAssertEqual(vehicle?.imageURL, "camry_image")
        XCTAssertEqual(vehicle?.registration.state, "CA")
        XCTAssertEqual(vehicle?.insurance.provider, "State Farm")
        XCTAssertEqual(vehicle?.insurance.coverageType, "Full")
        XCTAssertEqual(vehicle?.recalls.count, 1)
        XCTAssertEqual(vehicle?.recalls.first?.id, recallId)
        XCTAssertEqual(vehicle?.recalls.first?.title, "Airbag")
        XCTAssertEqual(vehicle?.maintenanceRecords.count, 1)
        XCTAssertEqual(vehicle?.maintenanceRecords.first?.id, maintId)
        XCTAssertEqual(vehicle?.maintenanceRecords.first?.title, "Tire Rotation")
        XCTAssertEqual(vehicle?.maintenanceRecords.first?.mileage, 30000)
        XCTAssertNotNil(vehicle?.valuation)
        XCTAssertEqual(vehicle?.valuation?.tradeIn, 20000)
        XCTAssertEqual(vehicle?.valuation?.privateSale, 25000)
        XCTAssertEqual(vehicle?.valuation?.dealer, 28000)
    }

    // MARK: - dictToVehicle: Missing Required Fields

    func testDictToVehicleReturnsNilForInvalidDocId() {
        let dict = makeValidVehicleDict()
        let vehicle = service.dictToVehicle(dict, docId: "not-a-uuid")
        XCTAssertNil(vehicle)
    }

    func testDictToVehicleReturnsNilForMissingMake() {
        var dict = makeValidVehicleDict()
        dict.removeValue(forKey: "make")
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertNil(vehicle)
    }

    func testDictToVehicleReturnsNilForMissingModel() {
        var dict = makeValidVehicleDict()
        dict.removeValue(forKey: "model")
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertNil(vehicle)
    }

    func testDictToVehicleReturnsNilForMissingYear() {
        var dict = makeValidVehicleDict()
        dict.removeValue(forKey: "year")
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertNil(vehicle)
    }

    // MARK: - dictToVehicle: Invalid Types

    func testDictToVehicleReturnsNilForWrongMakeType() {
        var dict = makeValidVehicleDict()
        dict["make"] = 123
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertNil(vehicle)
    }

    func testDictToVehicleReturnsNilForWrongModelType() {
        var dict = makeValidVehicleDict()
        dict["model"] = true
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertNil(vehicle)
    }

    func testDictToVehicleReturnsNilForWrongYearType() {
        var dict = makeValidVehicleDict()
        dict["year"] = "2023"
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertNil(vehicle)
    }

    // MARK: - dictToVehicle: Defaults for Optional Fields

    func testDictToVehicleDefaultsForMissingOptionals() {
        let dict: [String: Any] = [
            "make": "Honda",
            "model": "Civic",
            "year": 2024
        ]
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)

        XCTAssertNotNil(vehicle)
        XCTAssertEqual(vehicle?.trim, "")
        XCTAssertEqual(vehicle?.color, "")
        XCTAssertEqual(vehicle?.mileage, 0)
        XCTAssertEqual(vehicle?.vin, "")
        XCTAssertEqual(vehicle?.imageURL, "")
        XCTAssertEqual(vehicle?.registration.state, "")
        XCTAssertEqual(vehicle?.insurance.provider, "")
        XCTAssertEqual(vehicle?.insurance.coverageType, "")
        XCTAssertTrue(vehicle?.recalls.isEmpty ?? false)
        XCTAssertTrue(vehicle?.maintenanceRecords.isEmpty ?? false)
        XCTAssertNil(vehicle?.valuation)
    }

    func testDictToVehicleDefaultsMileageWhenMissing() {
        var dict = makeValidVehicleDict()
        dict.removeValue(forKey: "mileage")
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertEqual(vehicle?.mileage, 0)
    }

    func testDictToVehicleDefaultsTrimWhenMissing() {
        var dict = makeValidVehicleDict()
        dict.removeValue(forKey: "trim")
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertEqual(vehicle?.trim, "")
    }

    func testDictToVehicleDefaultsColorWhenMissing() {
        var dict = makeValidVehicleDict()
        dict.removeValue(forKey: "color")
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertEqual(vehicle?.color, "")
    }

    func testDictToVehicleDefaultsVinWhenMissing() {
        var dict = makeValidVehicleDict()
        dict.removeValue(forKey: "vin")
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertEqual(vehicle?.vin, "")
    }

    func testDictToVehicleDefaultsImageURLWhenMissing() {
        var dict = makeValidVehicleDict()
        dict.removeValue(forKey: "imageURL")
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertEqual(vehicle?.imageURL, "")
    }

    // MARK: - dictToVehicle: Empty Arrays

    func testDictToVehicleWithEmptyRecalls() {
        let dict = makeValidVehicleDict(recalls: [])
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertNotNil(vehicle)
        XCTAssertTrue(vehicle?.recalls.isEmpty ?? false)
    }

    func testDictToVehicleWithEmptyMaintenanceRecords() {
        let dict = makeValidVehicleDict(maintenanceRecords: [])
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertNotNil(vehicle)
        XCTAssertTrue(vehicle?.maintenanceRecords.isEmpty ?? false)
    }

    // MARK: - dictToVehicle: Null/Missing Optional Fields

    func testDictToVehicleWithNoValuation() {
        let dict = makeValidVehicleDict()
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertNil(vehicle?.valuation)
    }

    func testDictToVehicleWithNullValuation() {
        var dict = makeValidVehicleDict()
        dict["valuation"] = NSNull()
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertNil(vehicle?.valuation)
    }

    // MARK: - dictToVehicle: Recall Parsing

    func testDictToVehicleRecallParsing() {
        let recallId = UUID()
        let recallDate = Date(timeIntervalSince1970: 1_700_000_000)
        let recallDict = makeValidRecallDict(id: recallId, title: "FSD Safety", description: "Beta recall", source: "NHTSA", dateIssued: recallDate, isResolved: true)
        let dict = makeValidVehicleDict(recalls: [recallDict])

        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        let recall = vehicle?.recalls.first

        XCTAssertEqual(recall?.id, recallId)
        XCTAssertEqual(recall?.title, "FSD Safety")
        XCTAssertEqual(recall?.details, "Beta recall")
        XCTAssertEqual(recall?.source, "NHTSA")
        XCTAssertTrue(recall?.isResolved ?? false)
    }

    func testDictToVehicleRecallWithMissingId() {
        let recallDict: [String: Any] = [
            "title": "No ID Recall",
            "description": "Missing ID",
            "source": "NHTSA",
            "dateIssued": makeTimestamp(),
            "isResolved": false
        ]
        let dict = makeValidVehicleDict(recalls: [recallDict])
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        // Should skip the invalid recall
        XCTAssertTrue(vehicle?.recalls.isEmpty ?? false)
    }

    func testDictToVehicleRecallWithInvalidIdString() {
        let recallDict: [String: Any] = [
            "id": "not-a-uuid",
            "title": "Bad ID",
            "description": "",
            "source": "",
            "dateIssued": makeTimestamp(),
            "isResolved": false
        ]
        let dict = makeValidVehicleDict(recalls: [recallDict])
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertTrue(vehicle?.recalls.isEmpty ?? false)
    }

    func testDictToVehicleRecallWithMissingTitle() {
        let recallDict: [String: Any] = [
            "id": UUID().uuidString,
            "description": "No title",
            "source": "NHTSA",
            "dateIssued": makeTimestamp(),
            "isResolved": false
        ]
        let dict = makeValidVehicleDict(recalls: [recallDict])
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertTrue(vehicle?.recalls.isEmpty ?? false)
    }

    func testDictToVehicleMixedValidInvalidRecalls() {
        let validRecall = makeValidRecallDict(title: "Valid Recall")
        let invalidRecall: [String: Any] = [
            "id": "not-uuid",
            "title": "Invalid"
        ]
        let dict = makeValidVehicleDict(recalls: [validRecall, invalidRecall])
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertEqual(vehicle?.recalls.count, 1)
        XCTAssertEqual(vehicle?.recalls.first?.title, "Valid Recall")
    }

    func testDictToVehicleRecallDefaultValues() {
        let id = UUID()
        let recallDict: [String: Any] = [
            "id": id.uuidString,
            "title": "Minimal"
            // Missing: description, source, dateIssued, isResolved
        ]
        let dict = makeValidVehicleDict(recalls: [recallDict])
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        let recall = vehicle?.recalls.first

        XCTAssertNotNil(recall)
        XCTAssertEqual(recall?.details, "")
        XCTAssertEqual(recall?.source, "")
        XCTAssertFalse(recall?.isResolved ?? true)
    }

    func testDictToVehicleMultipleRecalls() {
        let recalls = (0..<5).map { i in
            makeValidRecallDict(title: "Recall \(i)")
        }
        let dict = makeValidVehicleDict(recalls: recalls)
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertEqual(vehicle?.recalls.count, 5)
    }

    // MARK: - dictToVehicle: Maintenance Record Parsing

    func testDictToVehicleMaintenanceParsing() {
        let maintId = UUID()
        let maintDate = Date(timeIntervalSince1970: 1_700_000_000)
        let maintDict = makeValidMaintenanceDict(id: maintId, title: "Oil Change", date: maintDate, provider: "Dealer", isCompleted: true, mileage: 15000)
        let dict = makeValidVehicleDict(maintenanceRecords: [maintDict])

        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        let record = vehicle?.maintenanceRecords.first

        XCTAssertEqual(record?.id, maintId)
        XCTAssertEqual(record?.title, "Oil Change")
        XCTAssertEqual(record?.provider, "Dealer")
        XCTAssertTrue(record?.isCompleted ?? false)
        XCTAssertEqual(record?.mileage, 15000)
    }

    func testDictToVehicleMaintenanceWithMissingId() {
        let maintDict: [String: Any] = [
            "title": "No ID",
            "date": makeTimestamp(),
            "provider": "Dealer",
            "isCompleted": true
        ]
        let dict = makeValidVehicleDict(maintenanceRecords: [maintDict])
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertTrue(vehicle?.maintenanceRecords.isEmpty ?? false)
    }

    func testDictToVehicleMaintenanceWithMissingTitle() {
        let maintDict: [String: Any] = [
            "id": UUID().uuidString,
            "date": makeTimestamp(),
            "provider": "Dealer",
            "isCompleted": true
        ]
        let dict = makeValidVehicleDict(maintenanceRecords: [maintDict])
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertTrue(vehicle?.maintenanceRecords.isEmpty ?? false)
    }

    func testDictToVehicleMaintenanceWithNilMileage() {
        let maintDict = makeValidMaintenanceDict(mileage: nil)
        let dict = makeValidVehicleDict(maintenanceRecords: [maintDict])
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertNil(vehicle?.maintenanceRecords.first?.mileage)
    }

    func testDictToVehicleMaintenanceDefaultValues() {
        let id = UUID()
        let maintDict: [String: Any] = [
            "id": id.uuidString,
            "title": "Minimal"
            // Missing: date, provider, isCompleted, mileage
        ]
        let dict = makeValidVehicleDict(maintenanceRecords: [maintDict])
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        let record = vehicle?.maintenanceRecords.first

        XCTAssertNotNil(record)
        XCTAssertEqual(record?.provider, "")
        XCTAssertFalse(record?.isCompleted ?? true)
        XCTAssertNil(record?.mileage)
    }

    // MARK: - dictToVehicle: Nested Object Parsing (Registration)

    func testDictToVehicleRegistrationParsing() {
        let regDate = Date(timeIntervalSince1970: 1_800_000_000)
        let regDict: [String: Any] = [
            "expiryDate": makeTimestamp(regDate),
            "state": "NY"
        ]
        let dict = makeValidVehicleDict(registration: regDict)
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)

        XCTAssertEqual(vehicle?.registration.state, "NY")
    }

    func testDictToVehicleRegistrationMissing() {
        var dict = makeValidVehicleDict()
        dict.removeValue(forKey: "registration")
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        // Default: empty state
        XCTAssertEqual(vehicle?.registration.state, "")
    }

    func testDictToVehicleRegistrationEmptyDict() {
        let dict = makeValidVehicleDict(registration: [:])
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertEqual(vehicle?.registration.state, "")
    }

    // MARK: - dictToVehicle: Nested Object Parsing (Insurance)

    func testDictToVehicleInsuranceParsing() {
        let insDate = Date(timeIntervalSince1970: 1_800_000_000)
        let insDict: [String: Any] = [
            "provider": "Geico",
            "coverageType": "Comprehensive",
            "expiryDate": makeTimestamp(insDate)
        ]
        let dict = makeValidVehicleDict(insurance: insDict)
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)

        XCTAssertEqual(vehicle?.insurance.provider, "Geico")
        XCTAssertEqual(vehicle?.insurance.coverageType, "Comprehensive")
    }

    func testDictToVehicleInsuranceMissing() {
        var dict = makeValidVehicleDict()
        dict.removeValue(forKey: "insurance")
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertEqual(vehicle?.insurance.provider, "")
        XCTAssertEqual(vehicle?.insurance.coverageType, "")
    }

    func testDictToVehicleInsuranceEmptyDict() {
        let dict = makeValidVehicleDict(insurance: [:])
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertEqual(vehicle?.insurance.provider, "")
        XCTAssertEqual(vehicle?.insurance.coverageType, "")
    }

    // MARK: - dictToVehicle: Valuation Parsing

    func testDictToVehicleValuationParsing() {
        let valDict = makeValidValuationDict(tradeIn: 20000, privateSale: 25000, dealer: 28000, trendAmount: 800, trendDirection: "down", trendDescription: "Seasonal dip")
        let dict = makeValidVehicleDict(valuation: valDict)
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)

        XCTAssertNotNil(vehicle?.valuation)
        XCTAssertEqual(vehicle?.valuation?.tradeIn, 20000)
        XCTAssertEqual(vehicle?.valuation?.privateSale, 25000)
        XCTAssertEqual(vehicle?.valuation?.dealer, 28000)
        XCTAssertEqual(vehicle?.valuation?.trend.amount, 800)
        XCTAssertEqual(vehicle?.valuation?.trend.direction, .down)
        XCTAssertEqual(vehicle?.valuation?.trend.summary, "Seasonal dip")
    }

    func testDictToVehicleValuationMissingTradeIn() {
        let valDict: [String: Any] = [
            "privateSale": 25000,
            "dealer": 28000,
            "trend": ["amount": 0, "direction": "up", "description": ""],
            "lastUpdated": makeTimestamp()
        ]
        let dict = makeValidVehicleDict(valuation: valDict)
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        // Should be nil because tradeIn is required
        XCTAssertNil(vehicle?.valuation)
    }

    func testDictToVehicleValuationMissingTrend() {
        let valDict: [String: Any] = [
            "tradeIn": 20000,
            "privateSale": 25000,
            "dealer": 28000,
            "lastUpdated": makeTimestamp()
        ]
        let dict = makeValidVehicleDict(valuation: valDict)
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        // Should be nil because trend is required
        XCTAssertNil(vehicle?.valuation)
    }

    func testDictToVehicleValuationInvalidTrendDirection() {
        let valDict = makeValidValuationDict(trendDirection: "invalid")
        let dict = makeValidVehicleDict(valuation: valDict)
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        // Invalid direction defaults to .up
        XCTAssertEqual(vehicle?.valuation?.trend.direction, .up)
    }

    func testDictToVehicleValuationTrendDefaultAmount() {
        let valDict: [String: Any] = [
            "tradeIn": 20000,
            "privateSale": 25000,
            "dealer": 28000,
            "trend": [
                "direction": "up",
                "description": "No amount"
            ] as [String: Any],
            "lastUpdated": makeTimestamp()
        ]
        let dict = makeValidVehicleDict(valuation: valDict)
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertEqual(vehicle?.valuation?.trend.amount, 0)
    }

    func testDictToVehicleValuationTrendDefaultDescription() {
        let valDict: [String: Any] = [
            "tradeIn": 20000,
            "privateSale": 25000,
            "dealer": 28000,
            "trend": [
                "amount": 100,
                "direction": "down"
            ] as [String: Any],
            "lastUpdated": makeTimestamp()
        ]
        let dict = makeValidVehicleDict(valuation: valDict)
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertEqual(vehicle?.valuation?.trend.summary, "")
    }

    // MARK: - vehicleToDict

    func testVehicleToDictBasicFields() {
        let vehicle = Vehicle(
            make: "Honda",
            model: "Accord",
            year: 2024,
            trim: "Sport",
            color: "Blue",
            mileage: 10000,
            vin: "VIN123",
            imageURL: "accord.jpg"
        )

        let dict = service.vehicleToDict(vehicle)

        XCTAssertEqual(dict["make"] as? String, "Honda")
        XCTAssertEqual(dict["model"] as? String, "Accord")
        XCTAssertEqual(dict["year"] as? Int, 2024)
        XCTAssertEqual(dict["trim"] as? String, "Sport")
        XCTAssertEqual(dict["color"] as? String, "Blue")
        XCTAssertEqual(dict["mileage"] as? Int, 10000)
        XCTAssertEqual(dict["vin"] as? String, "VIN123")
        XCTAssertEqual(dict["imageURL"] as? String, "accord.jpg")
    }

    func testVehicleToDictRegistration() {
        let regDate = Date(timeIntervalSince1970: 1_800_000_000)
        let vehicle = Vehicle(
            make: "Honda", model: "Civic", year: 2024,
            registration: RegistrationInfo(expiryDate: regDate, state: "TX")
        )

        let dict = service.vehicleToDict(vehicle)
        let regDict = dict["registration"] as? [String: Any]

        XCTAssertNotNil(regDict)
        XCTAssertEqual(regDict?["state"] as? String, "TX")
        XCTAssertNotNil(regDict?["expiryDate"] as? Timestamp)
    }

    func testVehicleToDictInsurance() {
        let insDate = Date(timeIntervalSince1970: 1_800_000_000)
        let vehicle = Vehicle(
            make: "Honda", model: "Civic", year: 2024,
            insurance: InsuranceInfo(provider: "Progressive", coverageType: "Liability", expiryDate: insDate)
        )

        let dict = service.vehicleToDict(vehicle)
        let insDict = dict["insurance"] as? [String: Any]

        XCTAssertNotNil(insDict)
        XCTAssertEqual(insDict?["provider"] as? String, "Progressive")
        XCTAssertEqual(insDict?["coverageType"] as? String, "Liability")
        XCTAssertNotNil(insDict?["expiryDate"] as? Timestamp)
    }

    func testVehicleToDictRecalls() {
        let recallId = UUID()
        let recall = Recall(id: recallId, title: "Engine", details: "Engine defect", source: "NHTSA", dateIssued: Date(), isResolved: true)
        let vehicle = Vehicle(make: "Honda", model: "Civic", year: 2024, recalls: [recall])

        let dict = service.vehicleToDict(vehicle)
        let recallsArray = dict["recalls"] as? [[String: Any]]

        XCTAssertNotNil(recallsArray)
        XCTAssertEqual(recallsArray?.count, 1)
        XCTAssertEqual(recallsArray?.first?["id"] as? String, recallId.uuidString)
        XCTAssertEqual(recallsArray?.first?["title"] as? String, "Engine")
        XCTAssertEqual(recallsArray?.first?["description"] as? String, "Engine defect")
        XCTAssertEqual(recallsArray?.first?["source"] as? String, "NHTSA")
        XCTAssertEqual(recallsArray?.first?["isResolved"] as? Bool, true)
    }

    func testVehicleToDictMaintenanceRecords() {
        let maintId = UUID()
        let record = MaintenanceRecord(id: maintId, title: "Oil Change", date: Date(), provider: "Shop", isCompleted: true, mileage: 5000)
        let vehicle = Vehicle(make: "Honda", model: "Civic", year: 2024, maintenanceRecords: [record])

        let dict = service.vehicleToDict(vehicle)
        let maintArray = dict["maintenanceRecords"] as? [[String: Any]]

        XCTAssertNotNil(maintArray)
        XCTAssertEqual(maintArray?.count, 1)
        XCTAssertEqual(maintArray?.first?["id"] as? String, maintId.uuidString)
        XCTAssertEqual(maintArray?.first?["title"] as? String, "Oil Change")
        XCTAssertEqual(maintArray?.first?["provider"] as? String, "Shop")
        XCTAssertEqual(maintArray?.first?["isCompleted"] as? Bool, true)
        XCTAssertEqual(maintArray?.first?["mileage"] as? Int, 5000)
    }

    func testVehicleToDictMaintenanceRecordNilMileage() {
        let record = MaintenanceRecord(id: UUID(), title: "Check", date: Date(), provider: "Shop", isCompleted: false, mileage: nil)
        let vehicle = Vehicle(make: "Honda", model: "Civic", year: 2024, maintenanceRecords: [record])

        let dict = service.vehicleToDict(vehicle)
        let maintArray = dict["maintenanceRecords"] as? [[String: Any]]

        XCTAssertNotNil(maintArray)
        // mileage should not be present when nil
        XCTAssertNil(maintArray?.first?["mileage"])
    }

    func testVehicleToDictWithValuation() {
        let val = Valuation(tradeIn: 20000, privateSale: 25000, dealer: 28000, trend: ValuationTrend(amount: 500, direction: .up, summary: "Going up"), lastUpdated: Date())
        let vehicle = Vehicle(make: "Honda", model: "Civic", year: 2024, valuation: val)

        let dict = service.vehicleToDict(vehicle)
        let valDict = dict["valuation"] as? [String: Any]

        XCTAssertNotNil(valDict)
        XCTAssertEqual(valDict?["tradeIn"] as? Int, 20000)
        XCTAssertEqual(valDict?["privateSale"] as? Int, 25000)
        XCTAssertEqual(valDict?["dealer"] as? Int, 28000)

        let trendDict = valDict?["trend"] as? [String: Any]
        XCTAssertEqual(trendDict?["amount"] as? Int, 500)
        XCTAssertEqual(trendDict?["direction"] as? String, "up")
        XCTAssertEqual(trendDict?["description"] as? String, "Going up")
    }

    func testVehicleToDictWithoutValuation() {
        let vehicle = Vehicle(make: "Honda", model: "Civic", year: 2024)
        let dict = service.vehicleToDict(vehicle)
        XCTAssertNil(dict["valuation"])
    }

    func testVehicleToDictEmptyRecalls() {
        let vehicle = Vehicle(make: "Honda", model: "Civic", year: 2024, recalls: [])
        let dict = service.vehicleToDict(vehicle)
        let recallsArray = dict["recalls"] as? [[String: Any]]
        XCTAssertNotNil(recallsArray)
        XCTAssertTrue(recallsArray?.isEmpty ?? false)
    }

    func testVehicleToDictTimestamps() {
        let vehicle = Vehicle(make: "Honda", model: "Civic", year: 2024)
        let dict = service.vehicleToDict(vehicle)
        // createdAt and updatedAt should be FieldValue.serverTimestamp()
        XCTAssertNotNil(dict["createdAt"])
        XCTAssertNotNil(dict["updatedAt"])
    }

    // MARK: - Round Trip: Vehicle -> Dict -> Vehicle

    func testRoundTripBasicVehicle() {
        let originalId = UUID()
        let vehicle = Vehicle(
            id: originalId,
            make: "Tesla",
            model: "Model 3",
            year: 2021,
            trim: "Long Range",
            color: "White",
            mileage: 28000,
            vin: "5YJ3E1EA1MF000001",
            imageURL: "tesla.jpg"
        )

        let dict = service.vehicleToDict(vehicle)
        let restored = service.dictToVehicle(dict, docId: originalId.uuidString)

        XCTAssertNotNil(restored)
        XCTAssertEqual(restored?.id, originalId)
        XCTAssertEqual(restored?.make, "Tesla")
        XCTAssertEqual(restored?.model, "Model 3")
        XCTAssertEqual(restored?.year, 2021)
        XCTAssertEqual(restored?.trim, "Long Range")
        XCTAssertEqual(restored?.color, "White")
        XCTAssertEqual(restored?.mileage, 28000)
        XCTAssertEqual(restored?.vin, "5YJ3E1EA1MF000001")
        XCTAssertEqual(restored?.imageURL, "tesla.jpg")
    }

    func testRoundTripWithRecalls() {
        let originalId = UUID()
        let recallId = UUID()
        let recall = Recall(id: recallId, title: "FSD Safety", details: "Beta recall", source: "NHTSA", dateIssued: Date(timeIntervalSince1970: 1_700_000_000), isResolved: false)
        let vehicle = Vehicle(id: originalId, make: "Tesla", model: "Model 3", year: 2021, recalls: [recall])

        let dict = service.vehicleToDict(vehicle)
        let restored = service.dictToVehicle(dict, docId: originalId.uuidString)

        XCTAssertEqual(restored?.recalls.count, 1)
        XCTAssertEqual(restored?.recalls.first?.id, recallId)
        XCTAssertEqual(restored?.recalls.first?.title, "FSD Safety")
        XCTAssertEqual(restored?.recalls.first?.details, "Beta recall")
        XCTAssertEqual(restored?.recalls.first?.source, "NHTSA")
        XCTAssertFalse(restored?.recalls.first?.isResolved ?? true)
    }

    func testRoundTripWithMaintenanceRecords() {
        let originalId = UUID()
        let maintId = UUID()
        let record = MaintenanceRecord(id: maintId, title: "Tire Rotation", date: Date(timeIntervalSince1970: 1_700_000_000), provider: "Discount Tire", isCompleted: true, mileage: 22000)
        let vehicle = Vehicle(id: originalId, make: "BMW", model: "M4", year: 2022, maintenanceRecords: [record])

        let dict = service.vehicleToDict(vehicle)
        let restored = service.dictToVehicle(dict, docId: originalId.uuidString)

        XCTAssertEqual(restored?.maintenanceRecords.count, 1)
        XCTAssertEqual(restored?.maintenanceRecords.first?.id, maintId)
        XCTAssertEqual(restored?.maintenanceRecords.first?.title, "Tire Rotation")
        XCTAssertEqual(restored?.maintenanceRecords.first?.provider, "Discount Tire")
        XCTAssertTrue(restored?.maintenanceRecords.first?.isCompleted ?? false)
        XCTAssertEqual(restored?.maintenanceRecords.first?.mileage, 22000)
    }

    func testRoundTripWithValuation() {
        let originalId = UUID()
        let val = Valuation(tradeIn: 29000, privateSale: 34200, dealer: 37000, trend: ValuationTrend(amount: 800, direction: .up, summary: "Market up"), lastUpdated: Date(timeIntervalSince1970: 1_700_000_000))
        let vehicle = Vehicle(id: originalId, make: "Tesla", model: "Model 3", year: 2021, valuation: val)

        let dict = service.vehicleToDict(vehicle)
        let restored = service.dictToVehicle(dict, docId: originalId.uuidString)

        XCTAssertNotNil(restored?.valuation)
        XCTAssertEqual(restored?.valuation?.tradeIn, 29000)
        XCTAssertEqual(restored?.valuation?.privateSale, 34200)
        XCTAssertEqual(restored?.valuation?.dealer, 37000)
        XCTAssertEqual(restored?.valuation?.trend.amount, 800)
        XCTAssertEqual(restored?.valuation?.trend.direction, .up)
        XCTAssertEqual(restored?.valuation?.trend.summary, "Market up")
    }

    func testRoundTripWithNilValuation() {
        let originalId = UUID()
        let vehicle = Vehicle(id: originalId, make: "Ford", model: "F150", year: 2023)

        let dict = service.vehicleToDict(vehicle)
        let restored = service.dictToVehicle(dict, docId: originalId.uuidString)

        XCTAssertNil(restored?.valuation)
    }

    func testRoundTripRegistration() {
        let originalId = UUID()
        let regDate = Date(timeIntervalSince1970: 1_800_000_000)
        let vehicle = Vehicle(
            id: originalId,
            make: "Honda", model: "Civic", year: 2024,
            registration: RegistrationInfo(expiryDate: regDate, state: "NY")
        )

        let dict = service.vehicleToDict(vehicle)
        let restored = service.dictToVehicle(dict, docId: originalId.uuidString)

        XCTAssertEqual(restored?.registration.state, "NY")
    }

    func testRoundTripInsurance() {
        let originalId = UUID()
        let insDate = Date(timeIntervalSince1970: 1_800_000_000)
        let vehicle = Vehicle(
            id: originalId,
            make: "Honda", model: "Civic", year: 2024,
            insurance: InsuranceInfo(provider: "Allstate", coverageType: "Full", expiryDate: insDate)
        )

        let dict = service.vehicleToDict(vehicle)
        let restored = service.dictToVehicle(dict, docId: originalId.uuidString)

        XCTAssertEqual(restored?.insurance.provider, "Allstate")
        XCTAssertEqual(restored?.insurance.coverageType, "Full")
    }

    // MARK: - Edge Cases

    func testDictToVehicleWithUnicodeFields() {
        let dict: [String: Any] = [
            "make": "\u{8C50}\u{7530}",
            "model": "\u{30AB}\u{30E0}\u{30EA}",
            "year": 2023,
            "trim": "\u{1F697} Special",
            "color": "R\u{00F6}t"
        ]
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertEqual(vehicle?.make, "\u{8C50}\u{7530}")
        XCTAssertEqual(vehicle?.model, "\u{30AB}\u{30E0}\u{30EA}")
        XCTAssertEqual(vehicle?.trim, "\u{1F697} Special")
    }

    func testDictToVehicleWithEmptyStringFields() {
        let dict: [String: Any] = [
            "make": "",
            "model": "",
            "year": 0
        ]
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertNotNil(vehicle)
        XCTAssertEqual(vehicle?.make, "")
        XCTAssertEqual(vehicle?.model, "")
        XCTAssertEqual(vehicle?.year, 0)
    }

    func testDictToVehicleNegativeYear() {
        let dict: [String: Any] = [
            "make": "Test",
            "model": "Car",
            "year": -1
        ]
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertEqual(vehicle?.year, -1)
    }

    func testDictToVehicleNegativeMileage() {
        var dict = makeValidVehicleDict()
        dict["mileage"] = -1000
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertEqual(vehicle?.mileage, -1000)
    }

    func testDictToVehicleWrongMileageType() {
        var dict = makeValidVehicleDict()
        dict["mileage"] = "25000" // String instead of Int
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        // Should default to 0 when type is wrong
        XCTAssertEqual(vehicle?.mileage, 0)
    }

    func testDictToVehicleEmptyDocId() {
        let dict = makeValidVehicleDict()
        let vehicle = service.dictToVehicle(dict, docId: "")
        XCTAssertNil(vehicle) // Empty string is not a valid UUID
    }

    func testDictToVehicleRecallsNotAnArray() {
        var dict = makeValidVehicleDict()
        dict["recalls"] = "not an array"
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertTrue(vehicle?.recalls.isEmpty ?? false)
    }

    func testDictToVehicleMaintenanceNotAnArray() {
        var dict = makeValidVehicleDict()
        dict["maintenanceRecords"] = 42
        let vehicle = service.dictToVehicle(dict, docId: UUID().uuidString)
        XCTAssertTrue(vehicle?.maintenanceRecords.isEmpty ?? false)
    }
}
