import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var garageVM: GarageViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            GarageHomeView()
                .tabItem {
                    Label("Garage", systemImage: "house.fill")
                }
                .tag(0)

            ValuationsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .tag(1)

            AlertsView()
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(FleetTheme.accentPurple)
    }
}
