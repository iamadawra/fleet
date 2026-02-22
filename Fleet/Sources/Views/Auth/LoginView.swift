import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var animateGradient = false

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    Color(hex: "F2EEFF"),
                    Color(hex: "EAF4FF"),
                    Color(hex: "F0FFF8"),
                    Color(hex: "F2EEFF")
                ],
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }

            VStack(spacing: 0) {
                Spacer()

                // App Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(
                            LinearGradient(
                                colors: [FleetTheme.accentPurple, FleetTheme.accentBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: FleetTheme.accentPurple.opacity(0.4), radius: 20, y: 10)

                    Image(systemName: "car.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 24)

                // App name
                Text("Fleet")
                    .font(.custom("Georgia", size: 44))
                    .fontWeight(.semibold)
                    .foregroundColor(FleetTheme.textPrimary)

                Text("Your garage, beautifully organized")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(FleetTheme.textSecondary)
                    .padding(.top, 4)

                Spacer()

                // Feature highlights
                VStack(spacing: 16) {
                    FeatureRow(icon: "car.2.fill", text: "Track all your vehicles in one place")
                    FeatureRow(icon: "bell.badge.fill", text: "Smart reminders for registration & insurance")
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Live KBB valuations for your fleet")
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)

                // Google Sign In Button
                Button(action: { authService.signIn() }) {
                    HStack(spacing: 12) {
                        Image(systemName: "g.circle.fill")
                            .font(.system(size: 22))
                        Text("Continue with Google")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [FleetTheme.accentPurple, FleetTheme.accentBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: FleetTheme.accentPurple.opacity(0.35), radius: 12, y: 6)
                }
                .padding(.horizontal, 24)
                .disabled(authService.isLoading)
                .opacity(authService.isLoading ? 0.7 : 1)

                if authService.isLoading {
                    ProgressView()
                        .padding(.top, 12)
                }

                if let error = authService.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(FleetTheme.accentRed)
                        .padding(.top, 8)
                }

                // Skip for demo — uses Firebase anonymous auth
                Button("Skip for now") {
                    Task {
                        await authService.signInAnonymously()
                    }
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(FleetTheme.textTertiary)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(FleetTheme.accentPurple)
                .frame(width: 36, height: 36)
                .background(FleetTheme.pastelLavender)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(FleetTheme.textSecondary)

            Spacer()
        }
    }
}
