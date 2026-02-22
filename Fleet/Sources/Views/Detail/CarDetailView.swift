import SwiftUI

struct CarDetailView: View {
    let vehicle: Vehicle
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            FleetTheme.detailBackground.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero image
                    heroSection

                    // Body content
                    VStack(alignment: .leading, spacing: 0) {
                        // Title row
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text(vehicle.make)
                                    .font(.custom("Georgia", size: 30))
                                    .fontWeight(.semibold)
                                    .foregroundColor(FleetTheme.textPrimary)
                                Text(vehicle.model)
                                    .font(.custom("Georgia", size: 30))
                                    .fontWeight(.semibold)
                                    .foregroundColor(FleetTheme.textPrimary)
                            }

                            Spacer()

                            if let val = vehicle.valuation {
                                VStack(alignment: .trailing, spacing: 3) {
                                    Text("KBB VALUE")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(FleetTheme.textTertiary)
                                        .kerning(1)
                                    Text("$\(NumberFormatter.currency.string(from: NSNumber(value: val.privateSale)) ?? "")")
                                        .font(.custom("Georgia", size: 20))
                                        .fontWeight(.medium)
                                        .foregroundColor(FleetTheme.accentPurple)
                                }
                            }
                        }
                        .padding(.bottom, 4)

                        Text("\(vehicle.subtitle) · \(NumberFormatter.currency.string(from: NSNumber(value: vehicle.mileage)) ?? "") mi")
                            .font(.system(size: 14))
                            .foregroundColor(FleetTheme.textSecondary)
                            .padding(.bottom, 22)

                        // Status grid
                        statusGrid
                            .padding(.bottom, 22)

                        // Service history
                        Text("Service History")
                            .font(.custom("Georgia", size: 18))
                            .fontWeight(.medium)
                            .foregroundColor(FleetTheme.textPrimary)
                            .padding(.bottom, 14)

                        serviceTimeline
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Circle()
                        .fill(.white.opacity(0.85))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(FleetTheme.textPrimary)
                        )
                        .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Circle()
                    .fill(.white.opacity(0.85))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(FleetTheme.textPrimary)
                    )
                    .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
            }
        }
    }

    // MARK: - Hero Section
    @ViewBuilder
    private var heroSection: some View {
        ZStack(alignment: .top) {
            vehicleImage
                .frame(height: 260)
                .clipped()

            LinearGradient(
                colors: [
                    .black.opacity(0.15),
                    .black.opacity(0.05),
                    Color(hex: "F2EEFF")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(height: 260)
    }

    @ViewBuilder
    private var vehicleImage: some View {
        let urlString: String = {
            switch vehicle.imageURL {
            case "tesla_model3": return "https://images.unsplash.com/photo-1617788138017-80ad40651399?w=700&q=80&auto=format&fit=crop"
            case "bmw_m4": return "https://images.unsplash.com/photo-1555215695-3004980ad54e?w=700&q=80&auto=format&fit=crop"
            case "jeep_wrangler": return "https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=700&q=80&auto=format&fit=crop"
            default: return ""
            }
        }()

        AsyncImage(url: URL(string: urlString)) { image in
            image.resizable().aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle().fill(FleetTheme.pastelBlue)
        }
    }

    // MARK: - Status Grid
    private var statusGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            // Registration
            StatusCardView(
                icon: "calendar",
                iconBgColor: FleetTheme.accentBlue.opacity(0.18),
                iconColor: FleetTheme.accentBlue,
                label: "REGISTRATION",
                value: vehicle.registration.formattedDate,
                subtitle: vehicle.registration.statusText,
                pillText: vehicle.registration.isExpiringSoon ? "Renew Soon" : "Active",
                pillType: vehicle.registration.isExpiringSoon ? .warning : .good,
                bgColor: FleetTheme.pastelBlue,
                accentColor: FleetTheme.accentBlue
            )

            // Insurance
            StatusCardView(
                icon: "shield.fill",
                iconBgColor: FleetTheme.accentGreen.opacity(0.18),
                iconColor: FleetTheme.accentGreen,
                label: "INSURANCE",
                value: vehicle.insurance.formattedDate,
                subtitle: vehicle.insurance.statusText,
                pillText: vehicle.insurance.isActive ? "Active" : "Expired",
                pillType: vehicle.insurance.isActive ? .good : .urgent,
                bgColor: FleetTheme.pastelMint,
                accentColor: FleetTheme.accentGreen
            )

            // Recalls
            let openRecalls = vehicle.recalls.filter { !$0.isResolved }
            StatusCardView(
                icon: "exclamationmark.triangle.fill",
                iconBgColor: FleetTheme.accentRed.opacity(0.18),
                iconColor: FleetTheme.accentRed,
                label: "RECALLS",
                value: openRecalls.isEmpty ? "None" : "\(openRecalls.count) Open",
                subtitle: openRecalls.first.map { "\($0.title) · \($0.source)" } ?? "No open recalls",
                pillText: openRecalls.isEmpty ? "Clear" : "Action Needed",
                pillType: openRecalls.isEmpty ? .good : .urgent,
                bgColor: FleetTheme.pastelRose,
                accentColor: FleetTheme.accentRed,
                showBadge: !openRecalls.isEmpty
            )

            // Maintenance
            let pendingMaint = vehicle.maintenanceRecords.filter { !$0.isCompleted }
            StatusCardView(
                icon: "wrench.fill",
                iconBgColor: FleetTheme.accentOrange.opacity(0.18),
                iconColor: FleetTheme.accentOrange,
                label: "MAINTENANCE",
                value: pendingMaint.isEmpty ? "Up to Date" : "\(pendingMaint.count) Pending",
                subtitle: pendingMaint.first?.title ?? "All services current",
                pillText: "Good",
                pillType: .good,
                bgColor: FleetTheme.pastelPeach,
                accentColor: FleetTheme.accentOrange
            )
        }
    }

    // MARK: - Service Timeline
    private var serviceTimeline: some View {
        VStack(spacing: 0) {
            ForEach(Array(vehicle.maintenanceRecords.enumerated()), id: \.element.id) { index, record in
                HStack(alignment: .top, spacing: 14) {
                    // Timeline dot and line
                    VStack(spacing: 0) {
                        Circle()
                            .fill(record.isCompleted ? FleetTheme.pastelMint : FleetTheme.pastelPeach)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: record.isCompleted ? "checkmark" : "clock")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(record.isCompleted ? FleetTheme.accentGreen : FleetTheme.accentOrange)
                            )

                        if index < vehicle.maintenanceRecords.count - 1 {
                            Rectangle()
                                .fill(Color.black.opacity(0.08))
                                .frame(width: 1)
                                .frame(minHeight: 20)
                                .padding(.vertical, 2)
                        }
                    }

                    // Content
                    VStack(alignment: .leading, spacing: 1) {
                        Text(record.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(FleetTheme.textPrimary)

                        Text(record.statusText + (record.isCompleted && !record.provider.isEmpty ? " · \(record.provider)" : ""))
                            .font(.system(size: 12))
                            .foregroundColor(FleetTheme.textSecondary)

                        Text(record.isCompleted ? "Completed" : "Upcoming")
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(record.isCompleted ? FleetTheme.accentGreen.opacity(0.2) : Color(hex: "F0A020").opacity(0.2))
                            .foregroundColor(record.isCompleted ? Color(hex: "1A7A56") : Color(hex: "B86800"))
                            .clipShape(Capsule())
                            .padding(.top, 4)
                    }
                    .padding(.top, 4)

                    Spacer()
                }
                .padding(.bottom, 14)
            }
        }
    }
}
