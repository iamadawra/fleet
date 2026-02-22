import SwiftUI
import GoogleSignIn

@main
struct FleetApp: App {
    @StateObject private var authService = AuthenticationService()
    @StateObject private var garageVM = GarageViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isSignedIn {
                    MainTabView()
                        .environmentObject(authService)
                        .environmentObject(garageVM)
                        .onAppear {
                            garageVM.loadSampleData()
                        }
                } else {
                    LoginView()
                        .environmentObject(authService)
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
