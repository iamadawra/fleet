import SwiftUI

struct VehicleCardView: View {
    let vehicle: Vehicle

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Car image
            vehicleImage
                .frame(height: vehicle.make == "Jeep" ? 180 : 210)
                .clipped()

            // Gradient overlay
            LinearGradient(
                colors: [
                    Color(hex: "0A0A1E").opacity(0.75),
                    Color(hex: "0A0A1E").opacity(0.1),
                    .clear
                ],
                startPoint: .bottom,
                endPoint: .top
            )

            // Content
            VStack(alignment: .leading, spacing: 0) {
                // Status badge
                HStack(spacing: 5) {
                    Text(vehicle.healthBadgeText)
                        .font(.system(size: 11, weight: .semibold))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(badgeBackground)
                .clipShape(Capsule())
                .overlay(
                    Capsule().strokeBorder(badgeBorder, lineWidth: 1)
                )
                .padding(.bottom, 8)

                Text(vehicle.displayName)
                    .font(.custom("Georgia", size: 22))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineSpacing(-0.3)

                Text(vehicle.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 2)

                if vehicle.make != "Jeep" {
                    HStack(spacing: 14) {
                        if vehicle.registration.isExpiringSoon {
                            statLabel(icon: "circle", text: "Reg: \(shortDate(vehicle.registration.expiryDate))")
                        } else {
                            statLabel(icon: "circle", text: "Ins: \(shortDate(vehicle.insurance.expiryDate))")
                        }
                        if let val = vehicle.valuation {
                            statLabel(icon: "star.fill", text: "$\(NumberFormatter.currency.string(from: NSNumber(value: val.privateSale)) ?? "") KBB")
                        }
                    }
                    .padding(.top, 10)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 16)
        }
        .frame(height: vehicle.make == "Jeep" ? 180 : 210)
        .clipShape(RoundedRectangle(cornerRadius: FleetTheme.cardRadius))
        .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
        .padding(.horizontal, 18)
        .padding(.bottom, 18)
    }

    @ViewBuilder
    private var vehicleImage: some View {
        switch vehicle.imageURL {
        case "tesla_model3":
            AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1617788138017-80ad40651399?w=700&q=80&auto=format&fit=crop")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(FleetTheme.pastelBlue)
            }
        case "bmw_m4":
            AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1555215695-3004980ad54e?w=700&q=80&auto=format&fit=crop")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(FleetTheme.pastelBlue)
            }
        case "jeep_wrangler":
            AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=700&q=80&auto=format&fit=crop")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(FleetTheme.pastelMint)
            }
        default:
            Rectangle().fill(FleetTheme.pastelBlue)
        }
    }

    private var badgeBackground: Color {
        switch vehicle.healthStatus {
        case .good: return FleetTheme.accentGreen.opacity(0.25)
        case .warning: return Color(hex: "F0A020").opacity(0.25)
        case .urgent: return Color(hex: "F0A020").opacity(0.25)
        }
    }

    private var badgeBorder: Color {
        switch vehicle.healthStatus {
        case .good: return FleetTheme.accentGreen.opacity(0.4)
        case .warning: return Color(hex: "F0A020").opacity(0.4)
        case .urgent: return Color(hex: "F0A020").opacity(0.4)
        }
    }

    private var badgeTextColor: Color {
        switch vehicle.healthStatus {
        case .good: return Color(hex: "5FE0A8")
        case .warning: return Color(hex: "F5C060")
        case .urgent: return Color(hex: "F5C060")
        }
    }

    private func statLabel(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .opacity(0.8)
            Text(text)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundColor(.white.opacity(0.75))
    }

    private func shortDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM yyyy"
        return fmt.string(from: date)
    }
}
