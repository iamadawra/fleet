import SwiftUI
import SwiftData

struct ValuationsView: View {
    @Query private var vehicles: [Vehicle]

    var body: some View {
        NavigationStack {
            ZStack {
                FleetTheme.valuationsBackground.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Valuations")
                                    .font(.custom("Georgia", size: 26))
                                    .fontWeight(.semibold)
                                    .foregroundColor(FleetTheme.textPrimary)
                                Text("Updated \(formattedDate)")
                                    .font(.system(size: 13))
                                    .foregroundColor(FleetTheme.textSecondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 3) {
                                Text("TOTAL FLEET")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(FleetTheme.textTertiary)
                                    .kerning(1)
                                Text(GarageStatsHelper.formattedTotalFleetValue(vehicles))
                                    .font(.custom("Georgia", size: 22))
                                    .fontWeight(.semibold)
                                    .foregroundColor(FleetTheme.accentPurple)
                            }
                        }
                        .padding(.horizontal, 22)
                        .padding(.top, 12)
                        .padding(.bottom, 18)

                        // Valuation cards
                        ForEach(vehicles.filter { $0.valuation != nil }) { vehicle in
                            NavigationLink(value: vehicle) {
                                ValuationCardView(vehicle: vehicle)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 18)
                            .padding(.bottom, 18)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationDestination(for: Vehicle.self) { vehicle in
                CarDetailView(vehicle: vehicle)
            }
        }
    }

    private var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, yyyy"
        return fmt.string(from: Date())
    }
}

struct ValuationCardView: View {
    let vehicle: Vehicle

    var valuation: Valuation { vehicle.valuation! }

    var isUp: Bool { valuation.trend.direction == .up }

    var body: some View {
        VStack(spacing: 0) {
            // Image section
            ZStack(alignment: .bottom) {
                vehicleImage
                    .frame(height: 160)
                    .clipped()

                LinearGradient(
                    colors: [.clear, .white],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }
            .frame(height: 160)

            // Body
            VStack(alignment: .leading, spacing: 0) {
                // Car name
                HStack(spacing: 6) {
                    Text(vehicle.displayName)
                        .font(.custom("Georgia", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(FleetTheme.textPrimary)
                    Text("\(vehicle.year)")
                        .font(.system(size: 14))
                        .foregroundColor(FleetTheme.textSecondary)
                }
                .padding(.bottom, 16)

                // Value range row
                HStack {
                    VStack(spacing: 3) {
                        Text("TRADE-IN")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(FleetTheme.textTertiary)
                            .kerning(1)
                        Text(valuation.formattedTradeIn)
                            .font(.custom("Georgia", size: 18))
                            .fontWeight(.medium)
                            .foregroundColor(FleetTheme.textPrimary)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 3) {
                        Text("PRIVATE SALE")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(FleetTheme.textTertiary)
                            .kerning(1)
                        Text("$\(NumberFormatter.currency.string(from: NSNumber(value: valuation.privateSale)) ?? "")")
                            .font(.custom("Georgia", size: 26))
                            .fontWeight(.semibold)
                            .foregroundColor(FleetTheme.accentPurple)
                    }

                    VStack(spacing: 3) {
                        Text("DEALER")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(FleetTheme.textTertiary)
                            .kerning(1)
                        Text(valuation.formattedDealer)
                            .font(.custom("Georgia", size: 18))
                            .fontWeight(.medium)
                            .foregroundColor(FleetTheme.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 10)

                // Range bar
                ZStack(alignment: .center) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.06))
                        .frame(height: 8)

                    // Fill
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: isUp ? [FleetTheme.accentPurple, FleetTheme.accentBlue] : [FleetTheme.accentBlue, FleetTheme.accentGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * 0.7)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    }
                    .frame(height: 8)

                    // Thumb
                    Circle()
                        .fill(.white)
                        .frame(width: 18, height: 18)
                        .overlay(
                            Circle()
                                .strokeBorder(isUp ? FleetTheme.accentPurple : FleetTheme.accentBlue, lineWidth: 3)
                        )
                        .shadow(color: FleetTheme.accentPurple.opacity(0.4), radius: 4, y: 2)
                }
                .frame(height: 18)
                .padding(.vertical, 6)

                // Trend indicator
                HStack(spacing: 6) {
                    Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isUp ? FleetTheme.accentGreen : FleetTheme.accentRed)

                    Text("\(isUp ? "Up" : "Down") $\(NumberFormatter.currency.string(from: NSNumber(value: valuation.trend.amount)) ?? "") from last month · \(valuation.trend.summary)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isUp ? Color(hex: "1A7A56") : Color(hex: "CC2B2B"))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isUp ? FleetTheme.pastelMint : FleetTheme.pastelRose)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .background(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
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
            ZStack {
                FleetTheme.pastelLavender
                Image(systemName: "car.fill")
                    .font(.system(size: 48))
                    .foregroundColor(FleetTheme.accentPurple.opacity(0.4))
            }
        }
    }
}
