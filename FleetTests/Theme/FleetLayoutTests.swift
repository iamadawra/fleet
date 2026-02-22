import XCTest
@testable import Fleet

final class FleetLayoutTests: XCTestCase {

    // MARK: - Scale Factor

    func testScaleFactorIsPositive() {
        XCTAssertGreaterThan(FleetLayout.scaleFactor, 0)
    }

    func testScaledReturnsPositiveValues() {
        XCTAssertGreaterThan(FleetLayout.scaled(100), 0)
    }

    func testScaledRespectsMinimum() {
        // Even with a very small input, minimum is enforced
        let result = FleetLayout.scaled(0.001, minimum: 10)
        XCTAssertGreaterThanOrEqual(result, 10)
    }

    func testScaledZeroReturnsZeroWhenNoMinimum() {
        XCTAssertEqual(FleetLayout.scaled(0), 0)
    }

    // MARK: - Card Heights

    func testVehicleCardHeightMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.vehicleCardHeight, 170)
    }

    func testVehicleCardHeightCompactMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.vehicleCardHeightCompact, 150)
    }

    func testVehicleCardHeightCompactSmallerThanStandard() {
        XCTAssertLessThan(FleetLayout.vehicleCardHeightCompact, FleetLayout.vehicleCardHeight)
    }

    func testPhotoPickerHeightMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.photoPickerHeight, 180)
    }

    func testHeroImageHeightMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.heroImageHeight, 200)
    }

    func testValuationImageHeightMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.valuationImageHeight, 120)
    }

    // MARK: - Button Heights

    func testButtonHeightMeetsMinimumTapTarget() {
        // 44pt is Apple's recommended minimum tap target
        XCTAssertGreaterThanOrEqual(FleetLayout.buttonHeight, 44)
    }

    func testTallButtonHeightMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.tallButtonHeight, 60)
    }

    func testTallButtonHeightTallerThanStandard() {
        XCTAssertGreaterThan(FleetLayout.tallButtonHeight, FleetLayout.buttonHeight)
    }

    // MARK: - Icon Containers

    func testIconSizeHierarchy() {
        XCTAssertLessThanOrEqual(FleetLayout.iconSmall, FleetLayout.iconStandard)
        XCTAssertLessThanOrEqual(FleetLayout.iconStandard, FleetLayout.iconMedium)
        XCTAssertLessThanOrEqual(FleetLayout.iconMedium, FleetLayout.iconLarge)
    }

    func testIconSmallMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.iconSmall, 26)
    }

    func testIconStandardMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.iconStandard, 28)
    }

    func testIconMediumMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.iconMedium, 28)
    }

    func testIconLargeMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.iconLarge, 30)
    }

    // MARK: - Small Elements

    func testStatusBadgeMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.statusBadge, 16)
    }

    func testDateBlockMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.dateBlock, 40)
    }

    func testRadioButtonMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.radioButton, 18)
    }

    func testRangeBarHeightMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.rangeBarHeight, 6)
    }

    func testRangeThumbSizeMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.rangeThumbSize, 14)
    }

    func testRangeThumbLargerThanBar() {
        XCTAssertGreaterThan(FleetLayout.rangeThumbSize, FleetLayout.rangeBarHeight)
    }

    // MARK: - Profile & App Icons

    func testProfilePhotoMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.profilePhoto, 60)
    }

    func testAppIconLargeMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.appIconLarge, 90)
    }

    func testAppIconMediumMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.appIconMedium, 60)
    }

    func testAppIconLargeBiggerThanMedium() {
        XCTAssertGreaterThan(FleetLayout.appIconLarge, FleetLayout.appIconMedium)
    }

    // MARK: - Thumbnails

    func testThumbnailWidthMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.thumbnailWidth, 72)
    }

    func testThumbnailHeightMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.thumbnailHeight, 50)
    }

    func testThumbnailWidthGreaterThanHeight() {
        XCTAssertGreaterThan(FleetLayout.thumbnailWidth, FleetLayout.thumbnailHeight)
    }

    // MARK: - Decorative Elements

    func testDecorativeCircleHierarchy() {
        XCTAssertLessThan(FleetLayout.decorativeCircleSmall, FleetLayout.decorativeCircleMedium)
        XCTAssertLessThan(FleetLayout.decorativeCircleMedium, FleetLayout.decorativeCircleLarge)
    }

    func testDecorativeCircleLargeMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.decorativeCircleLarge, 120)
    }

    func testDecorativeCircleMediumMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.decorativeCircleMedium, 70)
    }

    func testDecorativeCircleSmallMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.decorativeCircleSmall, 50)
    }

    // MARK: - Dividers

    func testStatsDividerHeightMeetsMinimum() {
        XCTAssertGreaterThanOrEqual(FleetLayout.statsDividerHeight, 20)
    }

    // MARK: - All Dimensions Positive

    func testAllDimensionsArePositive() {
        let dimensions: [CGFloat] = [
            FleetLayout.vehicleCardHeight,
            FleetLayout.vehicleCardHeightCompact,
            FleetLayout.photoPickerHeight,
            FleetLayout.heroImageHeight,
            FleetLayout.valuationImageHeight,
            FleetLayout.buttonHeight,
            FleetLayout.tallButtonHeight,
            FleetLayout.iconSmall,
            FleetLayout.iconStandard,
            FleetLayout.iconMedium,
            FleetLayout.iconLarge,
            FleetLayout.statusBadge,
            FleetLayout.dateBlock,
            FleetLayout.radioButton,
            FleetLayout.rangeBarHeight,
            FleetLayout.rangeThumbSize,
            FleetLayout.profilePhoto,
            FleetLayout.appIconLarge,
            FleetLayout.appIconMedium,
            FleetLayout.thumbnailWidth,
            FleetLayout.thumbnailHeight,
            FleetLayout.decorativeCircleLarge,
            FleetLayout.decorativeCircleMedium,
            FleetLayout.decorativeCircleSmall,
            FleetLayout.statsDividerHeight
        ]
        for dimension in dimensions {
            XCTAssertGreaterThan(dimension, 0, "All layout dimensions must be positive")
        }
    }
}
