import SwiftUI

enum PillType {
    case good, warning, urgent
}

struct StatusCardView: View {
    let icon: String
    let iconBgColor: Color
    let iconColor: Color
    let label: String
    let value: String
    let subtitle: String
    let pillText: String
    let pillType: PillType
    let bgColor: Color
    let accentColor: Color
    var showBadge: Bool = false

    var pillBgColor: Color {
        switch pillType {
        case .good: return FleetTheme.accentGreen.opacity(0.2)
        case .warning: return Color(hex: "F0A020").opacity(0.2)
        case .urgent: return FleetTheme.accentRed.opacity(0.2)
        }
    }

    var pillTextColor: Color {
        switch pillType {
        case .good: return Color(hex: "1A7A56")
        case .warning: return Color(hex: "B86800")
        case .urgent: return Color(hex: "CC2B2B")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconBgColor)
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }
            .padding(.bottom, 10)

            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(FleetTheme.textSecondary)
                .kerning(1)
                .padding(.bottom, 3)

            HStack(spacing: 0) {
                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(FleetTheme.textPrimary)
                if showBadge {
                    Text("!")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(FleetTheme.accentRed)
                        .clipShape(Circle())
                        .padding(.leading, 6)
                }
            }

            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(FleetTheme.textSecondary)
                .padding(.top, 2)

            Text(pillText)
                .font(.system(size: 10, weight: .semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(pillBgColor)
                .foregroundColor(pillTextColor)
                .clipShape(Capsule())
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            ZStack(alignment: .topTrailing) {
                bgColor
                Circle()
                    .fill(accentColor.opacity(0.3))
                    .frame(width: 70, height: 70)
                    .offset(x: 20, y: -20)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
