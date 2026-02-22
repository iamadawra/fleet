import UIKit

/// Responsive dimension system that scales UI elements proportionally
/// across different iPhone screen sizes.
///
/// All dimensions are designed for the iPhone 15 Pro reference width (393 pt)
/// and scale linearly based on the current device's screen width.
enum FleetLayout {

    // MARK: - Scale Factor

    private static let referenceWidth: CGFloat = 393

    static var scaleFactor: CGFloat {
        UIScreen.main.bounds.width / referenceWidth
    }

    /// Scales a value by the current scale factor, enforcing an optional minimum.
    static func scaled(_ value: CGFloat, minimum: CGFloat = 0) -> CGFloat {
        max(value * scaleFactor, minimum)
    }

    // MARK: - Card Heights

    /// Standard vehicle card height (e.g. garage list).
    static var vehicleCardHeight: CGFloat { scaled(210, minimum: 170) }

    /// Compact vehicle card height (e.g. Jeep cards).
    static var vehicleCardHeightCompact: CGFloat { scaled(180, minimum: 150) }

    /// Photo picker / loading / placeholder card height.
    static var photoPickerHeight: CGFloat { scaled(220, minimum: 180) }

    /// Hero image height on the detail screen.
    static var heroImageHeight: CGFloat { scaled(260, minimum: 200) }

    /// Vehicle image height inside a valuation card.
    static var valuationImageHeight: CGFloat { scaled(160, minimum: 120) }

    // MARK: - Button Heights

    /// Standard button height (primary CTAs).
    static var buttonHeight: CGFloat { scaled(56, minimum: 44) }

    /// Tall button height (e.g. add-vehicle dashed card).
    static var tallButtonHeight: CGFloat { scaled(80, minimum: 60) }

    // MARK: - Icon Containers

    /// Small icon container (e.g. plus-circle in garage).
    static var iconSmall: CGFloat { scaled(30, minimum: 26) }

    /// Timeline dot size in service history.
    static var iconStandard: CGFloat { scaled(32, minimum: 28) }

    /// Medium icon container (e.g. settings rows, status card).
    static var iconMedium: CGFloat { scaled(34, minimum: 28) }

    /// Large icon container (e.g. toolbar circles, feature row icons).
    static var iconLarge: CGFloat { scaled(36, minimum: 30) }

    // MARK: - Badges & Small Elements

    /// Status badge size (e.g. recall "!" badge).
    static var statusBadge: CGFloat { scaled(20, minimum: 16) }

    /// Date block size in event cards.
    static var dateBlock: CGFloat { scaled(48, minimum: 40) }

    /// Radio button / checkmark circle size.
    static var radioButton: CGFloat { scaled(22, minimum: 18) }

    /// Range bar height in valuation cards.
    static var rangeBarHeight: CGFloat { scaled(8, minimum: 6) }

    /// Range thumb size in valuation cards.
    static var rangeThumbSize: CGFloat { scaled(18, minimum: 14) }

    // MARK: - Profile & App Icons

    /// Profile photo size.
    static var profilePhoto: CGFloat { scaled(80, minimum: 60) }

    /// Large app icon (e.g. login screen).
    static var appIconLarge: CGFloat { scaled(120, minimum: 90) }

    /// Medium app icon (e.g. about screen).
    static var appIconMedium: CGFloat { scaled(80, minimum: 60) }

    // MARK: - Thumbnails

    /// Photo picker thumbnail width.
    static var thumbnailWidth: CGFloat { scaled(100, minimum: 72) }

    /// Photo picker thumbnail height.
    static var thumbnailHeight: CGFloat { scaled(70, minimum: 50) }

    // MARK: - Decorative Elements

    /// Large decorative circle (e.g. fleet health card).
    static var decorativeCircleLarge: CGFloat { scaled(160, minimum: 120) }

    /// Medium decorative circle.
    static var decorativeCircleMedium: CGFloat { scaled(100, minimum: 70) }

    /// Small decorative circle (e.g. status card corner).
    static var decorativeCircleSmall: CGFloat { scaled(70, minimum: 50) }

    // MARK: - Dividers

    /// Stats row divider height.
    static var statsDividerHeight: CGFloat { scaled(30, minimum: 20) }
}
