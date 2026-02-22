import Foundation
import GoogleSignIn

@MainActor
class AuthenticationService: ObservableObject {
    @Published var currentUser: FleetUser?
    @Published var isSignedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        restorePreviousSignIn()
    }

    func signIn() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            errorMessage = "Unable to find root view controller"
            return
        }

        isLoading = true
        errorMessage = nil

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard let self = self else { return }
            self.isLoading = false

            if let error = error {
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

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        currentUser = nil
        isSignedIn = false
    }

    private func restorePreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            guard let self = self else { return }
            if let user = user {
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
