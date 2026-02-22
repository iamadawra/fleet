import SwiftUI

struct LaunchLoadingView: View {
    @State private var animateGradient = false
    @State private var currentLineIndex = 0
    @State private var textOpacity: Double = 1.0
    @State private var iconRotation: Double = 0
    @State private var iconScale: Double = 1.0
    @State private var appeared = false

    private let oneLiners = [
        "Revving up the engine...",
        "Polishing the chrome...",
        "Checking the mirrors...",
        "Warming up the turbo...",
        "Syncing your speedometer...",
        "Detailing the dashboard...",
        "Tuning the exhaust note...",
        "Inflating the tires...",
        "Calibrating the GPS...",
        "Waxing the hood...",
        "Adjusting the seat warmers...",
        "Fueling up the fleet...",
        "Tightening the lug nuts...",
        "Buffing out the scratches...",
        "Unlocking the garage door..."
    ]

    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Animated gradient background (matches LoginView style)
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

                // App icon with gentle pulse animation
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
                        .scaleEffect(iconScale)

                    Image(systemName: "car.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(iconRotation))
                }
                .padding(.bottom, 24)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        iconScale = 1.06
                    }
                }

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

                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: FleetTheme.accentPurple))
                    .scaleEffect(1.2)
                    .padding(.bottom, 20)

                // Rotating one-liner text
                Text(oneLiners[currentLineIndex])
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(FleetTheme.textSecondary)
                    .opacity(textOpacity)
                    .animation(.easeInOut(duration: 0.4), value: textOpacity)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
            }
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.easeIn(duration: 0.5)) {
                    appeared = true
                }
            }
        }
        .onReceive(timer) { _ in
            cycleOneLiner()
        }
    }

    private func cycleOneLiner() {
        // Fade out
        withAnimation(.easeInOut(duration: 0.3)) {
            textOpacity = 0
        }

        // After fade out, change text and fade back in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            currentLineIndex = (currentLineIndex + 1) % oneLiners.count
            withAnimation(.easeInOut(duration: 0.3)) {
                textOpacity = 1
            }
        }
    }
}
