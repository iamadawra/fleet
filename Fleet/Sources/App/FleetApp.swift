import SwiftUI
import SwiftData
import GoogleSignIn
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    static var isFirebaseConfigured = false

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
            AppDelegate.isFirebaseConfigured = true
        }
        return true
    }
}

@main
struct FleetApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService = AuthenticationService()
    @StateObject private var firestoreService = FirestoreService()
    let modelContainer = ModelContainerConfig.makeContainer()

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isSignedIn {
                    MainTabView()
                        .environmentObject(authService)
                        .environmentObject(firestoreService)
                } else {
                    LoginView()
                        .environmentObject(authService)
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
            .onChange(of: authService.isSignedIn) { _, isSignedIn in
                handleAuthChange(isSignedIn: isSignedIn)
            }
        }
        .modelContainer(modelContainer)
    }

    private func handleAuthChange(isSignedIn: Bool) {
        let context = modelContainer.mainContext
        if isSignedIn, let userId = authService.currentUser?.id {
            firestoreService.startListening(userId: userId, modelContext: context)
            firestoreService.syncAllLocalVehicles(modelContext: context)
        } else {
            firestoreService.stopListening()
        }
    }
}
