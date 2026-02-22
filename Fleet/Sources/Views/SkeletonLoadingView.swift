import SwiftUI

// MARK: - Shimmer Effect Modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        Color.white.opacity(0.4),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(20))
                .offset(x: phase * 350)
                .clipped()
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Skeleton Bone (reusable placeholder shape)

struct SkeletonBone: View {
    var width: CGFloat? = nil
    var height: CGFloat = 14
    var radius: CGFloat = 8

    var body: some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(Color.black.opacity(0.06))
            .frame(width: width, height: height)
            .shimmer()
    }
}

// MARK: - Skeleton Loading View

struct SkeletonLoadingView: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            FleetTheme.garageBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skeleton Garage Header
                skeletonHeader
                    .padding(.horizontal, 22)
                    .padding(.top, 60)
                    .padding(.bottom, 20)

                // Skeleton Alert Chips
                skeletonChips
                    .padding(.bottom, 20)

                // Skeleton Vehicle Cards
                skeletonVehicleCard
                skeletonVehicleCard

                Spacer()

                // Skeleton Tab Bar
                skeletonTabBar
            }
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.easeIn(duration: 0.4)) {
                    appeared = true
                }
            }
        }
    }

    // MARK: - Header skeleton

    private var skeletonHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            SkeletonBone(width: 140, height: 12)
            SkeletonBone(width: 180, height: 26, radius: 10)
            SkeletonBone(width: 200, height: 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Alert chip skeletons

    private var skeletonChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { _ in
                    SkeletonBone(width: .random(in: 80...120), height: 28, radius: FleetTheme.pillRadius)
                }
            }
            .padding(.horizontal, 22)
        }
    }

    // MARK: - Vehicle card skeleton

    private var skeletonVehicleCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.black.opacity(0.05))
                .frame(height: 130)
                .shimmer()

            // Text area
            VStack(alignment: .leading, spacing: 8) {
                SkeletonBone(width: 70, height: 18, radius: FleetTheme.pillRadius)
                SkeletonBone(width: 190, height: 18, radius: 10)
                SkeletonBone(width: 140, height: 12)
                HStack(spacing: 14) {
                    SkeletonBone(width: 90, height: 12)
                    SkeletonBone(width: 100, height: 12)
                }
            }
            .padding(18)
        }
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: FleetTheme.cardRadius))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
        .padding(.horizontal, 18)
        .padding(.bottom, 18)
    }

    // MARK: - Tab bar skeleton

    private var skeletonTabBar: some View {
        HStack {
            ForEach(["house.fill", "chart.bar.fill", "bell.fill", "person.fill"], id: \.self) { icon in
                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color.black.opacity(0.12))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.black.opacity(0.06))
                        .frame(width: 32, height: 8)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}
