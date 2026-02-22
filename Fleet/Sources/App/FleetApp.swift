import SwiftUI
import SwiftData
import GoogleSignIn

@main
struct FleetApp: App {
    @StateObject private var authService = AuthenticationService()
    let modelContainer = ModelContainerConfig.makeContainer()

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isSignedIn {
                    MainTabView()
                        .environmentObject(authService)
                } else {
                    LoginView()
                        .environmentObject(authService)
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
        .modelContainer(modelContainer)
    }
}
