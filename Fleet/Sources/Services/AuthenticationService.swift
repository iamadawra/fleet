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

    init() {
        listenForAuthState()
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
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            errorMessage = "Unable to find root view controller"
            return
        }

        isLoading = true
        errorMessage = nil

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
    }

    // MARK: - Anonymous Sign-In

    func signInAnonymously() async {
        isLoading = true
        errorMessage = nil
        do {
            try await Auth.auth().signInAnonymously()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Sign Out

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
