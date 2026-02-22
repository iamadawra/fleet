import Foundation
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

@MainActor
class AuthenticationService: ObservableObject {
    @Published var currentUser: FleetUser?
    @Published var isSignedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    private var firebaseAvailable: Bool { AppDelegate.isFirebaseConfigured }

    private var googleSignInConfigured: Bool {
        GIDSignIn.sharedInstance.configuration != nil
    }

    init() {
        if firebaseAvailable {
            listenForAuthState()
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Auth State Listener

    private func listenForAuthState() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor in
                guard let self else { return }
                if let firebaseUser {
                    self.currentUser = FleetUser(
                        id: firebaseUser.uid,
                        name: firebaseUser.displayName ?? "User",
                        email: firebaseUser.email ?? "",
                        photoURL: firebaseUser.photoURL
                    )
                    self.isSignedIn = true
                } else {
                    self.currentUser = nil
                    self.isSignedIn = false
                }
            }
        }
    }

    // MARK: - Google Sign-In via Firebase

    func signIn() {
        guard googleSignInConfigured else {
            errorMessage = "Google Sign-In is not configured. Add GoogleService-Info.plist to enable authentication."
            return
        }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            errorMessage = "Unable to find root view controller"
            return
        }

        isLoading = true
        errorMessage = nil

        if firebaseAvailable {
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
                Task { @MainActor in
                    guard let self else { return }

                    if let error {
                        self.isLoading = false
                        self.errorMessage = error.localizedDescription
                        return
                    }

                    guard let googleUser = result?.user,
                          let idToken = googleUser.idToken?.tokenString else {
                        self.isLoading = false
                        self.errorMessage = "Failed to get Google credentials"
                        return
                    }

                    let credential = GoogleAuthProvider.credential(
                        withIDToken: idToken,
                        accessToken: googleUser.accessToken.tokenString
                    )

                    do {
                        try await Auth.auth().signIn(with: credential)
                    } catch {
                        self.errorMessage = error.localizedDescription
                    }
                    self.isLoading = false
                }
            }
        } else {
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
                Task { @MainActor in
                    guard let self else { return }
                    self.isLoading = false

                    if let error {
                        self.errorMessage = error.localizedDescription
                        return
                    }

                    guard let user = result?.user else { return }
                    self.currentUser = FleetUser(
                        id: user.userID ?? UUID().uuidString,
                        name: user.profile?.name ?? "User",
                        email: user.profile?.email ?? "",
                        photoURL: user.profile?.imageURL(withDimension: 200)
                    )
                    self.isSignedIn = true
                }
            }
        }
    }

    // MARK: - Anonymous / Demo Sign-In

    func signInAnonymously() async {
        isLoading = true
        errorMessage = nil

        if firebaseAvailable {
            do {
                try await Auth.auth().signInAnonymously()
            } catch {
                errorMessage = error.localizedDescription
            }
        } else {
            currentUser = FleetUser(
                id: "demo",
                name: "Alex Demo",
                email: "alex@example.com",
                photoURL: nil
            )
            isSignedIn = true
        }
        isLoading = false
    }

    // MARK: - Sign Out

    func signOut() {
        if googleSignInConfigured {
            GIDSignIn.sharedInstance.signOut()
        }
        if firebaseAvailable {
            try? Auth.auth().signOut()
        }
        currentUser = nil
        isSignedIn = false
    }
}
