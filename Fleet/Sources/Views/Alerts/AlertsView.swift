import SwiftUI
import SwiftData

struct AlertsView: View {
    @Query private var vehicles: [Vehicle]

    private var upcomingEvents: [FleetEvent] {
        GarageStatsHelper.upcomingEvents(vehicles)
    }

    private func vehicle(for event: FleetEvent) -> Vehicle? {
        vehicles.first { $0.id == event.vehicleId }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FleetTheme.alertsBackground.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Upcoming")
                                .font(.custom("Georgia", size: 28))
                                .fontWeight(.semibold)
                                .foregroundColor(FleetTheme.textPrimary)
                            Text("Stay ahead of every deadline")
                                .font(.system(size: 14))
                                .foregroundColor(FleetTheme.textSecondary)
                        }
                        .padding(.horizontal, 22)
                        .padding(.top, 12)
                        .padding(.bottom, 20)

                        // Fleet Health Score card
                        fleetHealthCard
                            .padding(.horizontal, 18)
                            .padding(.bottom, 20)

                        // Next 90 Days
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Next 90 Days")
                                .font(.custom("Georgia", size: 18))
                                .fontWeight(.medium)
                                .foregroundColor(FleetTheme.textPrimary)
                                .padding(.bottom, 14)

                            ForEach(upcomingEvents) { event in
                                if let vehicle = vehicle(for: event) {
                                    NavigationLink(value: vehicle) {
                                        EventCardView(event: event)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    EventCardView(event: event)
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationDestination(for: Vehicle.self) { vehicle in
                CarDetailView(vehicle: vehicle)
            }
        }
    }

    private var fleetHealthCard: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [FleetTheme.accentPurple, FleetTheme.accentBlue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Decorative circles
            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: FleetLayout.decorativeCircleLarge, height: FleetLayout.decorativeCircleLarge)
                .offset(x: 80, y: -60)

            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: FleetLayout.decorativeCircleMedium, height: FleetLayout.decorativeCircleMedium)
                .offset(x: -50, y: 60)

            VStack(alignment: .leading, spacing: 0) {
                Text("FLEET HEALTH SCORE")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .kerning(1.5)
                    .padding(.bottom, 6)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(GarageStatsHelper.fleetHealthScore(vehicles))")
                        .font(.custom("Georgia", size: 38))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text("/ 100")
                        .font(.custom("Georgia", size: 18))
                        .fontWeight(.light)
                        .foregroundColor(.white.opacity(0.7))
                }

                Text("\(GarageStatsHelper.alertCount(vehicles)) items need your attention")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.75))
                    .padding(.top, 6)

                HStack(spacing: 8) {
                    SummaryChipView(text: "\(vehicles.count) Vehicles")
                    SummaryChipView(text: "\(GarageStatsHelper.openRecallCount(vehicles)) Recall\(GarageStatsHelper.openRecallCount(vehicles) != 1 ? "s" : "")")
                    SummaryChipView(text: "\(GarageStatsHelper.expiringCount(vehicles)) Expiry")
                }
                .padding(.top, 18)
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: FleetTheme.accentPurple.opacity(0.35), radius: 20, y: 12)
    }
}

struct SummaryChipView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(.white.opacity(0.18))
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.25), lineWidth: 1))
    }
}

struct EventCardView: View {
    let event: FleetEvent

    var dateBlockColor: Color {
        switch event.category {
        case .registration: return FleetTheme.pastelRose
        case .recall: return FleetTheme.pastelPeach
        case .maintenance: return FleetTheme.pastelMint
        case .insurance: return FleetTheme.pastelBlue
        }
    }

    var tagBgColor: Color {
        switch event.category {
        case .registration: return FleetTheme.pastelBlue
        case .recall: return FleetTheme.pastelRose
        case .maintenance: return FleetTheme.pastelPeach
        case .insurance: return FleetTheme.pastelMint
        }
    }

    var tagTextColor: Color {
        switch event.category {
        case .registration: return FleetTheme.accentBlue
        case .recall: return Color(hex: "CC2B2B")
        case .maintenance: return Color(hex: "B85000")
        case .insurance: return Color(hex: "1A7A56")
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Date block
            VStack(spacing: 0) {
                Text(event.day)
                    .font(.custom("Georgia", size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(FleetTheme.textPrimary)
                Text(event.month.uppercased())
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(FleetTheme.textSecondary)
                    .kerning(1)
            }
            .frame(width: FleetLayout.dateBlock, height: FleetLayout.dateBlock)
            .background(dateBlockColor)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            // Event info
            VStack(alignment: .leading, spacing: 1) {
                Text(event.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(FleetTheme.textPrimary)
                Text(event.vehicleName)
                    .font(.system(size: 12))
                    .foregroundColor(FleetTheme.textSecondary)
                Text(event.category.rawValue.capitalized)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(tagTextColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(tagBgColor)
                    .clipShape(Capsule())
                    .padding(.top, 5)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(FleetTheme.textTertiary)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        .padding(.bottom, 12)
    }
}
