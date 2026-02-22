import SwiftUI

enum FleetTheme {
    // Pastel backgrounds
    static let pastelBlue = Color(hex: "D6E8FF")
    static let pastelLavender = Color(hex: "E8DCFF")
    static let pastelMint = Color(hex: "D4F5E9")
    static let pastelPeach = Color(hex: "FFE8D6")
    static let pastelRose = Color(hex: "FFD6E0")
    static let pastelSky = Color(hex: "D6F0FF")

    // Accent colors
    static let accentBlue = Color(hex: "4A90D9")
    static let accentPurple = Color(hex: "7B5EA7")
    static let accentGreen = Color(hex: "2ECC8B")
    static let accentOrange = Color(hex: "F0845C")
    static let accentRed = Color(hex: "E03535")

    // Text colors
    static let textPrimary = Color(hex: "1A1A2E")
    static let textSecondary = Color(hex: "6B7280")
    static let textTertiary = Color(hex: "9CA3AF")

    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [accentPurple, accentBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let garageBackground = LinearGradient(
        colors: [Color(hex: "F2EEFF"), Color(hex: "EAF4FF"), Color(hex: "F0FFF8")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let detailBackground = LinearGradient(
        colors: [Color(hex: "F2EEFF"), Color(hex: "EAF4FF"), Color(hex: "FAFAFA")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let alertsBackground = LinearGradient(
        colors: [Color(hex: "FFF0F5"), Color(hex: "F2EEFF"), Color(hex: "EAF4FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let valuationsBackground = LinearGradient(
        colors: [Color(hex: "FAFFF8"), Color(hex: "EAF4FF"), Color(hex: "F2EEFF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Card styling
    static let cardRadius: CGFloat = 22
    static let pillRadius: CGFloat = 100

    static var cardShadow: some ShapeStyle {
        Color.black.opacity(0.1)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
