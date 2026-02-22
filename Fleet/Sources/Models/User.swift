import Foundation

struct FleetUser {
    var id: String
    var name: String
    var email: String
    var photoURL: URL?

    var firstName: String {
        name.components(separatedBy: " ").first ?? name
    }
}
