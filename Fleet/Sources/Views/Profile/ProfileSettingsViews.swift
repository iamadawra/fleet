import SwiftUI
import SwiftData

// MARK: - Notifications Settings

struct NotificationsSettingsView: View {
    @AppStorage("notif_registrationReminders") private var registrationReminders = true
    @AppStorage("notif_insuranceReminders") private var insuranceReminders = true
    @AppStorage("notif_recallAlerts") private var recallAlerts = true
    @AppStorage("notif_maintenanceReminders") private var maintenanceReminders = true

    var body: some View {
        ZStack {
            FleetTheme.garageBackground.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    settingsCard {
                        VStack(spacing: 0) {
                            toggleRow(
                                icon: "car.badge.gearshape",
                                iconColor: FleetTheme.accentOrange,
                                title: "Registration Reminders",
                                subtitle: "Get notified before your registration expires",
                                isOn: $registrationReminders
                            )
                            Divider().padding(.leading, 60)
                            toggleRow(
                                icon: "shield.checkered",
                                iconColor: FleetTheme.accentBlue,
                                title: "Insurance Reminders",
                                subtitle: "Alerts when insurance renewal is approaching",
                                isOn: $insuranceReminders
                            )
                            Divider().padding(.leading, 60)
                            toggleRow(
                                icon: "exclamationmark.triangle",
                                iconColor: FleetTheme.accentRed,
                                title: "Recall Alerts",
                                subtitle: "Immediate notifications for new recalls",
                                isOn: $recallAlerts
                            )
                            Divider().padding(.leading, 60)
                            toggleRow(
                                icon: "wrench.and.screwdriver",
                                iconColor: FleetTheme.accentGreen,
                                title: "Maintenance Reminders",
                                subtitle: "Upcoming service and maintenance alerts",
                                isOn: $maintenanceReminders
                            )
                        }
                    }

                    Text("Notifications help you stay on top of important dates and safety alerts for your vehicles.")
                        .font(.system(size: 13))
                        .foregroundColor(FleetTheme.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleRow(icon: String, iconColor: Color, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 34, height: 34)
                .background(iconColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(FleetTheme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(FleetTheme.textSecondary)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(FleetTheme.accentPurple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Default Vehicle

struct DefaultVehicleSettingsView: View {
    @Query private var vehicles: [Vehicle]
    @AppStorage("defaultVehicleID") private var defaultVehicleID: String = ""

    var body: some View {
        ZStack {
            FleetTheme.garageBackground.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    if vehicles.isEmpty {
                        emptyState
                    } else {
                        settingsCard {
                            VStack(spacing: 0) {
                                ForEach(Array(vehicles.enumerated()), id: \.element.id) { index, vehicle in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            defaultVehicleID = vehicle.id.uuidString
                                        }
                                    } label: {
                                        vehicleRow(vehicle: vehicle)
                                    }
                                    .buttonStyle(.plain)

                                    if index < vehicles.count - 1 {
                                        Divider().padding(.leading, 60)
                                    }
                                }
                            }
                        }

                        Text("The default vehicle is shown first in your garage and used for quick actions.")
                            .font(.system(size: 13))
                            .foregroundColor(FleetTheme.textTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Default Vehicle")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func vehicleRow(vehicle: Vehicle) -> some View {
        let isSelected = vehicle.id.uuidString == defaultVehicleID

        return HStack(spacing: 14) {
            Image(systemName: "car.fill")
                .font(.system(size: 16))
                .foregroundColor(FleetTheme.accentBlue)
                .frame(width: 34, height: 34)
                .background(FleetTheme.accentBlue.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(vehicle.displayName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(FleetTheme.textPrimary)
                Text(vehicle.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(FleetTheme.textSecondary)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(FleetTheme.accentPurple)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Circle()
                    .strokeBorder(FleetTheme.textTertiary, lineWidth: 1.5)
                    .frame(width: 22, height: 22)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "car")
                .font(.system(size: 40))
                .foregroundColor(FleetTheme.textTertiary)
            Text("No Vehicles")
                .font(.custom("Georgia", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(FleetTheme.textPrimary)
            Text("Add a vehicle to your garage first to set a default.")
                .font(.system(size: 14))
                .foregroundColor(FleetTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
        .padding(.horizontal, 40)
    }
}

// MARK: - Valuation Preferences

enum ValuationRefreshFrequency: String, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"

    var id: String { rawValue }
}

struct ValuationPreferencesView: View {
    @AppStorage("valuation_autoRefresh") private var autoRefresh = true
    @AppStorage("valuation_refreshFrequency") private var refreshFrequency: String = ValuationRefreshFrequency.monthly.rawValue

    var body: some View {
        ZStack {
            FleetTheme.garageBackground.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    settingsCard {
                        VStack(spacing: 0) {
                            toggleRow(
                                icon: "arrow.triangle.2.circlepath",
                                iconColor: FleetTheme.accentGreen,
                                title: "Auto-refresh Valuations",
                                subtitle: "Automatically update vehicle valuations",
                                isOn: $autoRefresh
                            )

                            if autoRefresh {
                                Divider().padding(.leading, 60)

                                HStack(spacing: 14) {
                                    Image(systemName: "calendar.badge.clock")
                                        .font(.system(size: 16))
                                        .foregroundColor(FleetTheme.accentBlue)
                                        .frame(width: 34, height: 34)
                                        .background(FleetTheme.accentBlue.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Refresh Frequency")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(FleetTheme.textPrimary)
                                        Text("How often valuations are updated")
                                            .font(.system(size: 12))
                                            .foregroundColor(FleetTheme.textSecondary)
                                    }

                                    Spacer()

                                    Picker("", selection: $refreshFrequency) {
                                        ForEach(ValuationRefreshFrequency.allCases) { frequency in
                                            Text(frequency.rawValue).tag(frequency.rawValue)
                                        }
                                    }
                                    .labelsHidden()
                                    .tint(FleetTheme.accentPurple)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .animation(.easeInOut(duration: 0.25), value: autoRefresh)
                    }

                    Text("Valuations are estimated based on your vehicle's make, model, year, mileage, and current market trends.")
                        .font(.system(size: 13))
                        .foregroundColor(FleetTheme.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Valuation Preferences")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleRow(icon: String, iconColor: Color, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 34, height: 34)
                .background(iconColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(FleetTheme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(FleetTheme.textSecondary)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(FleetTheme.accentPurple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Privacy & Security

struct PrivacySecuritySettingsView: View {
    @AppStorage("privacy_requireFaceID") private var requireFaceID = false
    @AppStorage("privacy_shareAnalytics") private var shareAnalytics = true

    var body: some View {
        ZStack {
            FleetTheme.garageBackground.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    settingsCard {
                        VStack(spacing: 0) {
                            toggleRow(
                                icon: "faceid",
                                iconColor: FleetTheme.accentPurple,
                                title: "Require Face ID",
                                subtitle: "Authenticate with Face ID when opening Fleet",
                                isOn: $requireFaceID
                            )
                            Divider().padding(.leading, 60)
                            toggleRow(
                                icon: "chart.bar",
                                iconColor: FleetTheme.accentBlue,
                                title: "Share Analytics",
                                subtitle: "Help improve Fleet by sharing anonymous usage data",
                                isOn: $shareAnalytics
                            )
                        }
                    }

                    settingsCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Data Storage")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(FleetTheme.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.top, 12)

                            infoRow(label: "Storage", value: "On-device + iCloud")
                            Divider().padding(.leading, 16)
                            infoRow(label: "Encryption", value: "AES-256")
                            Divider().padding(.leading, 16)
                            infoRow(label: "Sync", value: "End-to-end encrypted")
                        }
                        .padding(.bottom, 12)
                    }

                    Text("Your vehicle data is stored securely on your device and synced with iCloud using end-to-end encryption.")
                        .font(.system(size: 13))
                        .foregroundColor(FleetTheme.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Privacy & Security")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleRow(icon: String, iconColor: Color, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 34, height: 34)
                .background(iconColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(FleetTheme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(FleetTheme.textSecondary)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(FleetTheme.accentPurple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(FleetTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(FleetTheme.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

// MARK: - Help & Support

struct HelpSupportView: View {
    @State private var expandedQuestion: String?

    private let faqs: [(question: String, answer: String)] = [
        (
            "How do I add a vehicle?",
            "Tap the \"Add a vehicle\" button at the bottom of your Garage. Enter your vehicle's make, model, year, and other details. You can also add your VIN for automatic recall tracking."
        ),
        (
            "How are valuations calculated?",
            "Fleet estimates your vehicle's value based on its make, model, year, trim, mileage, and current market conditions. Valuations are updated regularly using real market data to provide accurate estimates."
        ),
        (
            "How do I delete a vehicle?",
            "In your Garage, long-press on a vehicle card to reveal the context menu, then tap \"Delete Vehicle\". This action cannot be undone, so make sure you want to remove the vehicle permanently."
        ),
        (
            "Is my data synced across devices?",
            "Yes, Fleet syncs your vehicle data securely through iCloud. All data is encrypted end-to-end, ensuring only you can access your information. Changes appear across all your signed-in devices automatically."
        )
    ]

    var body: some View {
        ZStack {
            FleetTheme.garageBackground.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    // FAQ Section
                    settingsCard {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Frequently Asked Questions")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(FleetTheme.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.top, 14)
                                .padding(.bottom, 8)

                            ForEach(Array(faqs.enumerated()), id: \.offset) { index, faq in
                                if index > 0 {
                                    Divider().padding(.leading, 16)
                                }
                                faqRow(question: faq.question, answer: faq.answer)
                            }
                        }
                        .padding(.bottom, 4)
                    }

                    // Contact section
                    settingsCard {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Get in Touch")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(FleetTheme.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.top, 14)
                                .padding(.bottom, 8)

                            contactRow(icon: "envelope.fill", iconColor: FleetTheme.accentBlue, title: "Email Support", detail: "support@fleetapp.com")
                            Divider().padding(.leading, 60)
                            contactRow(icon: "globe", iconColor: FleetTheme.accentPurple, title: "Website", detail: "fleetapp.com")
                        }
                        .padding(.bottom, 12)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func faqRow(question: String, answer: String) -> some View {
        DisclosureGroup(
            isExpanded: Binding(
                get: { expandedQuestion == question },
                set: { isExpanded in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        expandedQuestion = isExpanded ? question : nil
                    }
                }
            )
        ) {
            Text(answer)
                .font(.system(size: 14))
                .foregroundColor(FleetTheme.textSecondary)
                .padding(.top, 8)
                .padding(.bottom, 4)
        } label: {
            Text(question)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(FleetTheme.textPrimary)
                .multilineTextAlignment(.leading)
        }
        .tint(FleetTheme.accentPurple)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func contactRow(icon: String, iconColor: Color, title: String, detail: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 34, height: 34)
                .background(iconColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(FleetTheme.textPrimary)
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundColor(FleetTheme.textSecondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - About Fleet

struct AboutFleetView: View {
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    var body: some View {
        ZStack {
            FleetTheme.garageBackground.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // App icon and name
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(
                                    LinearGradient(
                                        colors: [FleetTheme.accentPurple, FleetTheme.accentBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: FleetTheme.accentPurple.opacity(0.3), radius: 12, y: 4)

                            Image(systemName: "car.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }

                        Text("Fleet")
                            .font(.custom("Georgia", size: 28))
                            .fontWeight(.semibold)
                            .foregroundColor(FleetTheme.textPrimary)

                        Text("Your personal vehicle manager")
                            .font(.system(size: 14))
                            .foregroundColor(FleetTheme.textSecondary)
                    }
                    .padding(.top, 20)

                    // Version info
                    settingsCard {
                        VStack(spacing: 0) {
                            infoRow(label: "Version", value: appVersion)
                            Divider().padding(.leading, 16)
                            infoRow(label: "Build", value: buildNumber)
                            Divider().padding(.leading, 16)
                            infoRow(label: "Platform", value: "iOS 17+")
                            Divider().padding(.leading, 16)
                            infoRow(label: "Framework", value: "SwiftUI + SwiftData")
                        }
                    }

                    // Credits
                    settingsCard {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Credits")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(FleetTheme.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.top, 14)
                                .padding(.bottom, 8)

                            creditRow(title: "Design & Development", detail: "Fleet Team")
                            Divider().padding(.leading, 16)
                            creditRow(title: "Vehicle Data", detail: "NHTSA & Market APIs")
                            Divider().padding(.leading, 16)
                            creditRow(title: "Icons", detail: "SF Symbols")
                        }
                        .padding(.bottom, 12)
                    }

                    // Links
                    settingsCard {
                        VStack(spacing: 0) {
                            linkRow(icon: "doc.text", title: "Terms of Service")
                            Divider().padding(.leading, 60)
                            linkRow(icon: "hand.raised", title: "Privacy Policy")
                            Divider().padding(.leading, 60)
                            linkRow(icon: "star", title: "Rate Fleet on the App Store")
                        }
                    }

                    Text("Made with care for car enthusiasts everywhere.")
                        .font(.system(size: 13))
                        .foregroundColor(FleetTheme.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("About Fleet")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(FleetTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(FleetTheme.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func creditRow(title: String, detail: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(FleetTheme.textSecondary)
            Spacer()
            Text(detail)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(FleetTheme.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func linkRow(icon: String, title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(FleetTheme.accentPurple)
                .frame(width: 34, height: 34)
                .background(FleetTheme.accentPurple.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(FleetTheme.textPrimary)

            Spacer()

            Image(systemName: "arrow.up.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(FleetTheme.textTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Shared Card Helper

private extension View {
    func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .background(.white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            .padding(.horizontal, 18)
    }
}
