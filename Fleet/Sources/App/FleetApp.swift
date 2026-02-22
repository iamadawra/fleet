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
    @StateObject private var toastManager = ToastManager()
    @State private var isLaunching = true
    let modelContainer = ModelContainerConfig.makeContainer()

    var body: some Scene {
        WindowGroup {
            Group {
                if isLaunching {
                    LaunchLoadingView()
                        .transition(.opacity)
                } else if authService.isSignedIn {
                    MainTabView()
                        .environmentObject(authService)
                        .environmentObject(firestoreService)
                        .environmentObject(toastManager)
                        .transition(.opacity)
                } else {
                    LoginView()
                        .environmentObject(authService)
                        .environmentObject(toastManager)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: isLaunching)
            .toast(toastManager)
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
            .onChange(of: authService.isSignedIn) { _, isSignedIn in
                handleAuthChange(isSignedIn: isSignedIn)
            }
            .onAppear {
                checkModelContainerHealth()
                finishLaunching()
            }
            .onReceive(firestoreService.$listenerError) { error in
                if let error {
                    toastManager.showError(error)
                }
            }
        }
        .modelContainer(modelContainer)
    }

    private func handleAuthChange(isSignedIn: Bool) {
        let context = modelContainer.mainContext
        if isSignedIn, let userId = authService.currentUser?.id {
            firestoreService.startListening(userId: userId, modelContext: context)
            Task {
                do {
                    try await firestoreService.syncAllLocalVehicles(modelContext: context)
                } catch {
                    toastManager.showError("Failed to sync vehicles: \(error.localizedDescription)")
                }
            }
        } else {
            firestoreService.stopListening()
        }
    }

    private func finishLaunching() {
        Task {
            // Allow Firebase and auth services to initialize.
            // Keeps the loading screen visible long enough for
            // network-dependent setup on slow connections.
            try? await Task.sleep(for: .seconds(2))
            let deadline = Date().addingTimeInterval(8)
            while authService.isLoading, Date() < deadline {
                try? await Task.sleep(for: .milliseconds(250))
            }
            withAnimation {
                isLaunching = false
            }
        }
    }

    private func checkModelContainerHealth() {
        if ModelContainerConfig.didFallBackToInMemory {
            toastManager.showWarning("Using temporary storage. Data will not persist between sessions.")
        }
    }
}
