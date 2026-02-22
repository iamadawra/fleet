import SwiftUI
import SwiftData

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Query private var vehicles: [Vehicle]

    var body: some View {
        NavigationStack {
            ZStack {
                FleetTheme.garageBackground.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Profile header
                        VStack(spacing: 16) {
                            if let photoURL = authService.currentUser?.photoURL {
                                AsyncImage(url: photoURL) { image in
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    profilePlaceholder
                                }
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                            } else {
                                profilePlaceholder
                            }

                            VStack(spacing: 4) {
                                Text(authService.currentUser?.name ?? "User")
                                    .font(.custom("Georgia", size: 24))
                                    .fontWeight(.semibold)
                                    .foregroundColor(FleetTheme.textPrimary)
                                Text(authService.currentUser?.email ?? "")
                                    .font(.system(size: 14))
                                    .foregroundColor(FleetTheme.textSecondary)
                            }
                        }
                        .padding(.top, 20)

                        // Stats row
                        HStack(spacing: 0) {
                            profileStat(value: "\(vehicles.count)", label: "Vehicles")
                            Divider().frame(height: 30)
                            profileStat(value: "\(GarageStatsHelper.alertCount(vehicles))", label: "Alerts")
                            Divider().frame(height: 30)
                            profileStat(value: GarageStatsHelper.formattedTotalFleetValue(vehicles), label: "Fleet Value")
                        }
                        .padding(.vertical, 16)
                        .background(.white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
                        .padding(.horizontal, 18)

                        // Settings sections
                        VStack(spacing: 2) {
                            NavigationLink(destination: NotificationsSettingsView()) {
                                settingsRow(icon: "bell.fill", color: FleetTheme.accentPurple, title: "Notifications")
                            }
                            NavigationLink(destination: DefaultVehicleSettingsView()) {
                                settingsRow(icon: "car.fill", color: FleetTheme.accentBlue, title: "Default Vehicle")
                            }
                            NavigationLink(destination: ValuationPreferencesView()) {
                                settingsRow(icon: "dollarsign.circle.fill", color: FleetTheme.accentGreen, title: "Valuation Preferences")
                            }
                            NavigationLink(destination: PrivacySecuritySettingsView()) {
                                settingsRow(icon: "lock.fill", color: FleetTheme.accentOrange, title: "Privacy & Security")
                            }
                        }
                        .background(.white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
                        .padding(.horizontal, 18)

                        VStack(spacing: 2) {
                            NavigationLink(destination: HelpSupportView()) {
                                settingsRow(icon: "questionmark.circle.fill", color: FleetTheme.textSecondary, title: "Help & Support")
                            }
                            NavigationLink(destination: AboutFleetView()) {
                                settingsRow(icon: "info.circle.fill", color: FleetTheme.textSecondary, title: "About Fleet")
                            }
                        }
                        .background(.white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
                        .padding(.horizontal, 18)

                        // Sign out button
                        Button(action: { authService.signOut() }) {
                            Text("Sign Out")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(FleetTheme.accentRed)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(.white.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
                        }
                        .padding(.horizontal, 18)

                        Text("Fleet v1.0.0")
                            .font(.system(size: 12))
                            .foregroundColor(FleetTheme.textTertiary)
                            .padding(.bottom, 40)
                    }
                }
            }
        }
    }

    private var profilePlaceholder: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [FleetTheme.accentPurple, FleetTheme.accentBlue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 80, height: 80)
            .overlay(
                Text(authService.currentUser?.firstName.prefix(1).uppercased() ?? "U")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
            )
    }

    private func profileStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("Georgia", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(FleetTheme.textPrimary)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(FleetTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func settingsRow(icon: String, color: Color, title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(FleetTheme.textPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(FleetTheme.textTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
