import XCTest
@testable import Fleet

final class GarageStatsHelperTests: XCTestCase {

    // MARK: - Helpers

    private func makeVehicle(
        make: String = "Test",
        model: String = "Car",
        year: Int = 2023,
        mileage: Int = 10000,
        recalls: [Recall] = [],
        maintenanceRecords: [MaintenanceRecord] = [],
        valuation: Valuation? = nil,
        registrationDaysFromNow: Int = 180,
        insuranceDaysFromNow: Int = 180
    ) -> Vehicle {
        let regDate = Calendar.current.date(byAdding: .day, value: registrationDaysFromNow, to: Date())!
        let insDate = Calendar.current.date(byAdding: .day, value: insuranceDaysFromNow, to: Date())!
        return Vehicle(
            make: make,
            model: model,
            year: year,
            mileage: mileage,
            registration: RegistrationInfo(expiryDate: regDate, state: "CA"),
            insurance: InsuranceInfo(provider: "Test Insurance", coverageType: "Full", expiryDate: insDate),
            recalls: recalls,
            maintenanceRecords: maintenanceRecords,
            valuation: valuation
        )
    }

    private func makeRecall(isResolved: Bool = false) -> Recall {
        Recall(id: UUID(), title: "Test Recall", details: "", source: "NHTSA", dateIssued: Date(), isResolved: isResolved)
    }

    private func makeMaintenanceRecord(isCompleted: Bool = false, daysFromNow: Int = 30) -> MaintenanceRecord {
        let date = Calendar.current.date(byAdding: .day, value: daysFromNow, to: Date())!
        return MaintenanceRecord(id: UUID(), title: "Maintenance", date: date, provider: "Shop", isCompleted: isCompleted, mileage: nil)
    }

    private func makeValuation(privateSale: Int) -> Valuation {
        Valuation(tradeIn: privateSale - 5000, privateSale: privateSale, dealer: privateSale + 3000, trend: ValuationTrend(amount: 0, direction: .up, summary: ""), lastUpdated: Date())
    }

    // MARK: - totalFleetValue

    func testTotalFleetValueEmptyArray() {
        XCTAssertEqual(GarageStatsHelper.totalFleetValue([]), 0)
    }

    func testTotalFleetValueSingleVehicle() {
        let vehicle = makeVehicle(valuation: makeValuation(privateSale: 30000))
        XCTAssertEqual(GarageStatsHelper.totalFleetValue([vehicle]), 30000)
    }

    func testTotalFleetValueMultipleVehicles() {
        let v1 = makeVehicle(valuation: makeValuation(privateSale: 30000))
        let v2 = makeVehicle(valuation: makeValuation(privateSale: 50000))
        let v3 = makeVehicle(valuation: makeValuation(privateSale: 20000))
        XCTAssertEqual(GarageStatsHelper.totalFleetValue([v1, v2, v3]), 100000)
    }

    func testTotalFleetValueSkipsNilValuations() {
        let v1 = makeVehicle(valuation: makeValuation(privateSale: 30000))
        let v2 = makeVehicle(valuation: nil)
        let v3 = makeVehicle(valuation: makeValuation(privateSale: 20000))
        XCTAssertEqual(GarageStatsHelper.totalFleetValue([v1, v2, v3]), 50000)
    }

    func testTotalFleetValueAllNilValuations() {
        let v1 = makeVehicle(valuation: nil)
        let v2 = makeVehicle(valuation: nil)
        XCTAssertEqual(GarageStatsHelper.totalFleetValue([v1, v2]), 0)
    }

    // MARK: - formattedTotalFleetValue

    func testFormattedTotalFleetValueEmpty() {
        let result = GarageStatsHelper.formattedTotalFleetValue([])
        XCTAssertTrue(result.hasPrefix("$"))
    }

    func testFormattedTotalFleetValueWithCommas() {
        let v1 = makeVehicle(valuation: makeValuation(privateSale: 100000))
        let result = GarageStatsHelper.formattedTotalFleetValue([v1])
        XCTAssertTrue(result.hasPrefix("$"))
        XCTAssertTrue(result.contains(",") || result.contains("100000"))
    }

    // MARK: - alertCount

    func testAlertCountEmptyArray() {
        XCTAssertEqual(GarageStatsHelper.alertCount([]), 0)
    }

    func testAlertCountNoAlerts() {
        let vehicle = makeVehicle(registrationDaysFromNow: 180)
        XCTAssertEqual(GarageStatsHelper.alertCount([vehicle]), 0)
    }

    func testAlertCountWithUnresolvedRecalls() {
        let vehicle = makeVehicle(
            recalls: [makeRecall(isResolved: false)],
            registrationDaysFromNow: 180
        )
        XCTAssertEqual(GarageStatsHelper.alertCount([vehicle]), 1)
    }

    func testAlertCountWithResolvedRecallsOnly() {
        let vehicle = makeVehicle(
            recalls: [makeRecall(isResolved: true)],
            registrationDaysFromNow: 180
        )
        XCTAssertEqual(GarageStatsHelper.alertCount([vehicle]), 0)
    }

    func testAlertCountWithExpiringSoonRegistration() {
        let vehicle = makeVehicle(registrationDaysFromNow: 15)
        XCTAssertEqual(GarageStatsHelper.alertCount([vehicle]), 1)
    }

    func testAlertCountWithBothRecallAndExpiring() {
        let vehicle = makeVehicle(
            recalls: [makeRecall(isResolved: false)],
            registrationDaysFromNow: 15
        )
        XCTAssertEqual(GarageStatsHelper.alertCount([vehicle]), 2)
    }

    func testAlertCountMultipleVehicles() {
        let v1 = makeVehicle(recalls: [makeRecall()], registrationDaysFromNow: 15) // 2 alerts
        let v2 = makeVehicle(recalls: [makeRecall()], registrationDaysFromNow: 180) // 1 alert
        let v3 = makeVehicle(registrationDaysFromNow: 180) // 0 alerts
        XCTAssertEqual(GarageStatsHelper.alertCount([v1, v2, v3]), 3)
    }

    func testAlertCountExpiredRegistrationNotCountedAsExpiringSoon() {
        // Expired (days <= 0) is not "expiring soon" (> 0 and < 30)
        let vehicle = makeVehicle(registrationDaysFromNow: -10)
        XCTAssertEqual(GarageStatsHelper.alertCount([vehicle]), 0)
    }

    // MARK: - fleetHealthScore

    func testFleetHealthScoreEmpty() {
        XCTAssertEqual(GarageStatsHelper.fleetHealthScore([]), 100)
    }

    func testFleetHealthScorePerfect() {
        let vehicle = makeVehicle(registrationDaysFromNow: 180)
        XCTAssertEqual(GarageStatsHelper.fleetHealthScore([vehicle]), 100)
    }

    func testFleetHealthScoreWithRecalls() {
        let vehicle = makeVehicle(
            recalls: [makeRecall(isResolved: false)],
            registrationDaysFromNow: 180
        )
        // 100 - 1*10 = 90
        XCTAssertEqual(GarageStatsHelper.fleetHealthScore([vehicle]), 90)
    }

    func testFleetHealthScoreWithMultipleRecalls() {
        let vehicle = makeVehicle(
            recalls: [makeRecall(), makeRecall(), makeRecall()],
            registrationDaysFromNow: 180
        )
        // 100 - 3*10 = 70
        XCTAssertEqual(GarageStatsHelper.fleetHealthScore([vehicle]), 70)
    }

    func testFleetHealthScoreWithExpiring() {
        let vehicle = makeVehicle(registrationDaysFromNow: 15)
        // 100 - 1*4 = 96
        XCTAssertEqual(GarageStatsHelper.fleetHealthScore([vehicle]), 96)
    }

    func testFleetHealthScoreMinimumIsZero() {
        let recalls = (0..<15).map { _ in makeRecall() }
        let vehicle = makeVehicle(recalls: recalls, registrationDaysFromNow: 180)
        // 100 - 15*10 = -50 -> clamped to 0
        XCTAssertEqual(GarageStatsHelper.fleetHealthScore([vehicle]), 0)
    }

    func testFleetHealthScoreCombinedPenalties() {
        let vehicle = makeVehicle(
            recalls: [makeRecall(), makeRecall()],
            registrationDaysFromNow: 15
        )
        // 100 - 2*10 - 1*4 = 76
        XCTAssertEqual(GarageStatsHelper.fleetHealthScore([vehicle]), 76)
    }

    func testFleetHealthScoreMultipleVehicles() {
        let v1 = makeVehicle(recalls: [makeRecall()], registrationDaysFromNow: 180) // 1 recall
        let v2 = makeVehicle(registrationDaysFromNow: 15) // 1 expiring
        // 100 - 1*10 - 1*4 = 86
        XCTAssertEqual(GarageStatsHelper.fleetHealthScore([v1, v2]), 86)
    }

    // MARK: - openRecallCount

    func testOpenRecallCountEmpty() {
        XCTAssertEqual(GarageStatsHelper.openRecallCount([]), 0)
    }

    func testOpenRecallCountNoRecalls() {
        let vehicle = makeVehicle()
        XCTAssertEqual(GarageStatsHelper.openRecallCount([vehicle]), 0)
    }

    func testOpenRecallCountWithOpenRecalls() {
        let vehicle = makeVehicle(recalls: [makeRecall(), makeRecall()])
        XCTAssertEqual(GarageStatsHelper.openRecallCount([vehicle]), 2)
    }

    func testOpenRecallCountExcludesResolved() {
        let vehicle = makeVehicle(recalls: [
            makeRecall(isResolved: false),
            makeRecall(isResolved: true),
            makeRecall(isResolved: false)
        ])
        XCTAssertEqual(GarageStatsHelper.openRecallCount([vehicle]), 2)
    }

    func testOpenRecallCountMultipleVehicles() {
        let v1 = makeVehicle(recalls: [makeRecall()])
        let v2 = makeVehicle(recalls: [makeRecall(), makeRecall()])
        let v3 = makeVehicle()
        XCTAssertEqual(GarageStatsHelper.openRecallCount([v1, v2, v3]), 3)
    }

    // MARK: - expiringCount

    func testExpiringCountEmpty() {
        XCTAssertEqual(GarageStatsHelper.expiringCount([]), 0)
    }

    func testExpiringCountNoneExpiring() {
        let vehicle = makeVehicle(registrationDaysFromNow: 180)
        XCTAssertEqual(GarageStatsHelper.expiringCount([vehicle]), 0)
    }

    func testExpiringCountWithExpiring() {
        let vehicle = makeVehicle(registrationDaysFromNow: 15)
        XCTAssertEqual(GarageStatsHelper.expiringCount([vehicle]), 1)
    }

    func testExpiringCountExpiredNotCounted() {
        let vehicle = makeVehicle(registrationDaysFromNow: -10)
        XCTAssertEqual(GarageStatsHelper.expiringCount([vehicle]), 0)
    }

    func testExpiringCountMultipleVehicles() {
        let v1 = makeVehicle(registrationDaysFromNow: 15)
        let v2 = makeVehicle(registrationDaysFromNow: 180)
        let v3 = makeVehicle(registrationDaysFromNow: 10)
        XCTAssertEqual(GarageStatsHelper.expiringCount([v1, v2, v3]), 2)
    }

    // MARK: - upcomingEvents

    func testUpcomingEventsEmpty() {
        XCTAssertTrue(GarageStatsHelper.upcomingEvents([]).isEmpty)
    }

    func testUpcomingEventsRegistrationWithin180Days() {
        let vehicle = makeVehicle(make: "Tesla", model: "Model 3", year: 2021, registrationDaysFromNow: 90)
        let events = GarageStatsHelper.upcomingEvents([vehicle])
        let regEvents = events.filter { $0.category == .registration }
        XCTAssertEqual(regEvents.count, 1)
        XCTAssertEqual(regEvents.first?.title, "Registration Renewal")
        XCTAssertTrue(regEvents.first?.vehicleName.contains("Tesla Model 3") ?? false)
    }

    func testUpcomingEventsRegistrationBeyond180Days() {
        let vehicle = makeVehicle(registrationDaysFromNow: 200)
        let events = GarageStatsHelper.upcomingEvents([vehicle])
        let regEvents = events.filter { $0.category == .registration }
        XCTAssertTrue(regEvents.isEmpty)
    }

    func testUpcomingEventsRegistrationExpired() {
        let vehicle = makeVehicle(registrationDaysFromNow: -10)
        let events = GarageStatsHelper.upcomingEvents([vehicle])
        let regEvents = events.filter { $0.category == .registration }
        XCTAssertTrue(regEvents.isEmpty, "Expired registrations should not be upcoming events")
    }

    func testUpcomingEventsInsuranceWithin180Days() {
        let vehicle = makeVehicle(
            make: "BMW", model: "M4",
            registrationDaysFromNow: 200,
            insuranceDaysFromNow: 90
        )
        let events = GarageStatsHelper.upcomingEvents([vehicle])
        let insEvents = events.filter { $0.category == .insurance }
        XCTAssertEqual(insEvents.count, 1)
        XCTAssertEqual(insEvents.first?.title, "Insurance Renewal")
        XCTAssertTrue(insEvents.first?.vehicleName.contains("Test Insurance") ?? false)
    }

    func testUpcomingEventsInsuranceBeyond180Days() {
        let vehicle = makeVehicle(registrationDaysFromNow: 200, insuranceDaysFromNow: 200)
        let events = GarageStatsHelper.upcomingEvents([vehicle])
        let insEvents = events.filter { $0.category == .insurance }
        XCTAssertTrue(insEvents.isEmpty)
    }

    func testUpcomingEventsOpenRecalls() {
        let vehicle = makeVehicle(
            make: "Honda", model: "Civic",
            recalls: [
                Recall(id: UUID(), title: "Brake Issue", details: "", source: "NHTSA", dateIssued: Date(), isResolved: false)
            ],
            registrationDaysFromNow: 200,
            insuranceDaysFromNow: 200
        )
        let events = GarageStatsHelper.upcomingEvents([vehicle])
        let recallEvents = events.filter { $0.category == .recall }
        XCTAssertEqual(recallEvents.count, 1)
        XCTAssertEqual(recallEvents.first?.title, "Brake Issue")
    }

    func testUpcomingEventsResolvedRecallsExcluded() {
        let vehicle = makeVehicle(
            recalls: [makeRecall(isResolved: true)],
            registrationDaysFromNow: 200,
            insuranceDaysFromNow: 200
        )
        let events = GarageStatsHelper.upcomingEvents([vehicle])
        let recallEvents = events.filter { $0.category == .recall }
        XCTAssertTrue(recallEvents.isEmpty)
    }

    func testUpcomingEventsUpcomingMaintenance() {
        let maintDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        let record = MaintenanceRecord(id: UUID(), title: "Oil Change", date: maintDate, provider: "Shop", isCompleted: false, mileage: 30000)
        let vehicle = makeVehicle(
            make: "Jeep", model: "Wrangler",
            maintenanceRecords: [record],
            registrationDaysFromNow: 200,
            insuranceDaysFromNow: 200
        )
        let events = GarageStatsHelper.upcomingEvents([vehicle])
        let maintEvents = events.filter { $0.category == .maintenance }
        XCTAssertEqual(maintEvents.count, 1)
        XCTAssertEqual(maintEvents.first?.title, "Oil Change")
    }

    func testUpcomingEventsCompletedMaintenanceExcluded() {
        let record = MaintenanceRecord(id: UUID(), title: "Oil Change", date: Date(), provider: "Shop", isCompleted: true, mileage: 30000)
        let vehicle = makeVehicle(
            maintenanceRecords: [record],
            registrationDaysFromNow: 200,
            insuranceDaysFromNow: 200
        )
        let events = GarageStatsHelper.upcomingEvents([vehicle])
        let maintEvents = events.filter { $0.category == .maintenance }
        XCTAssertTrue(maintEvents.isEmpty)
    }

    func testUpcomingEventsSortedByDate() {
        let v1 = makeVehicle(registrationDaysFromNow: 100, insuranceDaysFromNow: 200)
        let v2 = makeVehicle(registrationDaysFromNow: 10, insuranceDaysFromNow: 200)

        let events = GarageStatsHelper.upcomingEvents([v1, v2])

        if events.count >= 2 {
            XCTAssertTrue(events[0].date <= events[1].date, "Events should be sorted by date ascending")
        }
    }

    func testUpcomingEventsMultipleVehicles() {
        let v1 = makeVehicle(
            make: "Tesla", model: "Model 3", year: 2021,
            recalls: [makeRecall()],
            maintenanceRecords: [makeMaintenanceRecord(isCompleted: false)],
            registrationDaysFromNow: 90,
            insuranceDaysFromNow: 90
        )
        let v2 = makeVehicle(
            make: "BMW", model: "M4", year: 2022,
            registrationDaysFromNow: 30,
            insuranceDaysFromNow: 200
        )

        let events = GarageStatsHelper.upcomingEvents([v1, v2])
        // v1: reg + insurance + recall + maintenance = 4
        // v2: reg = 1
        XCTAssertTrue(events.count >= 4)
    }

    func testUpcomingEventsMaintenanceMileageLabel() {
        let record = MaintenanceRecord(id: UUID(), title: "Tire Rotation", date: Calendar.current.date(byAdding: .day, value: 30, to: Date())!, provider: "Shop", isCompleted: false, mileage: 30000)
        let vehicle = makeVehicle(
            make: "Test", model: "Car",
            maintenanceRecords: [record],
            registrationDaysFromNow: 200,
            insuranceDaysFromNow: 200
        )
        let events = GarageStatsHelper.upcomingEvents([vehicle])
        let maintEvents = events.filter { $0.category == .maintenance }
        XCTAssertEqual(maintEvents.count, 1)
        XCTAssertTrue(maintEvents.first?.vehicleName.contains("mi") ?? false)
    }

    func testUpcomingEventsMaintenanceNoMileage() {
        let record = MaintenanceRecord(id: UUID(), title: "Inspection", date: Calendar.current.date(byAdding: .day, value: 30, to: Date())!, provider: "Shop", isCompleted: false, mileage: nil)
        let vehicle = makeVehicle(
            make: "Test", model: "Car",
            maintenanceRecords: [record],
            registrationDaysFromNow: 200,
            insuranceDaysFromNow: 200
        )
        let events = GarageStatsHelper.upcomingEvents([vehicle])
        let maintEvents = events.filter { $0.category == .maintenance }
        XCTAssertEqual(maintEvents.count, 1)
    }

    // MARK: - Edge Cases with Large Fleets

    func testManyVehicles() {
        let vehicles = (0..<100).map { i in
            makeVehicle(
                make: "Make\(i)",
                model: "Model\(i)",
                valuation: makeValuation(privateSale: 10000 + i * 1000),
                registrationDaysFromNow: 180
            )
        }
        XCTAssertEqual(GarageStatsHelper.totalFleetValue(vehicles), (0..<100).reduce(0) { $0 + 10000 + $1 * 1000 })
        XCTAssertEqual(GarageStatsHelper.fleetHealthScore(vehicles), 100)
    }

    func testSingleVehicleFleet() {
        let vehicle = makeVehicle(
            valuation: makeValuation(privateSale: 50000),
            registrationDaysFromNow: 180
        )
        XCTAssertEqual(GarageStatsHelper.totalFleetValue([vehicle]), 50000)
        XCTAssertEqual(GarageStatsHelper.fleetHealthScore([vehicle]), 100)
        XCTAssertEqual(GarageStatsHelper.alertCount([vehicle]), 0)
        XCTAssertEqual(GarageStatsHelper.openRecallCount([vehicle]), 0)
        XCTAssertEqual(GarageStatsHelper.expiringCount([vehicle]), 0)
    }
}
