import XCTest
@testable import Fleet

final class UserTests: XCTestCase {

    // MARK: - Initialization

    func testBasicInitialization() {
        let user = FleetUser(id: "user123", name: "John Doe", email: "john@example.com", photoURL: nil)

        XCTAssertEqual(user.id, "user123")
        XCTAssertEqual(user.name, "John Doe")
        XCTAssertEqual(user.email, "john@example.com")
        XCTAssertNil(user.photoURL)
    }

    func testInitializationWithPhotoURL() {
        let url = URL(string: "https://example.com/photo.jpg")!
        let user = FleetUser(id: "user456", name: "Jane Smith", email: "jane@example.com", photoURL: url)

        XCTAssertEqual(user.photoURL, url)
    }

    // MARK: - firstName

    func testFirstNameSingleWord() {
        let user = FleetUser(id: "1", name: "John", email: "", photoURL: nil)
        XCTAssertEqual(user.firstName, "John")
    }

    func testFirstNameMultipleWords() {
        let user = FleetUser(id: "1", name: "John Michael Doe", email: "", photoURL: nil)
        XCTAssertEqual(user.firstName, "John")
    }

    func testFirstNameTwoWords() {
        let user = FleetUser(id: "1", name: "John Doe", email: "", photoURL: nil)
        XCTAssertEqual(user.firstName, "John")
    }

    func testFirstNameEmpty() {
        let user = FleetUser(id: "1", name: "", email: "", photoURL: nil)
        XCTAssertEqual(user.firstName, "")
    }

    func testFirstNameWithLeadingSpace() {
        let user = FleetUser(id: "1", name: " John", email: "", photoURL: nil)
        // components(separatedBy: " ").first returns "" for leading space
        XCTAssertEqual(user.firstName, "")
    }

    // MARK: - Edge Cases

    func testEmptyId() {
        let user = FleetUser(id: "", name: "Test", email: "test@test.com", photoURL: nil)
        XCTAssertEqual(user.id, "")
    }

    func testEmptyEmail() {
        let user = FleetUser(id: "1", name: "Test", email: "", photoURL: nil)
        XCTAssertEqual(user.email, "")
    }

    func testUnicodeInName() {
        let user = FleetUser(id: "1", name: "\u{592A}\u{90CE} \u{5C71}\u{7530}", email: "", photoURL: nil)
        XCTAssertEqual(user.firstName, "\u{592A}\u{90CE}")
    }

    func testEmojiInName() {
        let user = FleetUser(id: "1", name: "\u{1F600} Happy", email: "", photoURL: nil)
        XCTAssertEqual(user.firstName, "\u{1F600}")
    }

    func testVeryLongName() {
        let longName = String(repeating: "A", count: 10_000)
        let user = FleetUser(id: "1", name: longName, email: "", photoURL: nil)
        XCTAssertEqual(user.firstName, longName)
    }

    func testNameWithMultipleSpaces() {
        let user = FleetUser(id: "1", name: "John  Doe", email: "", photoURL: nil)
        XCTAssertEqual(user.firstName, "John")
    }

    func testInvalidPhotoURL() {
        let user = FleetUser(id: "1", name: "Test", email: "", photoURL: nil)
        XCTAssertNil(user.photoURL)
    }

    func testSpecialCharactersInEmail() {
        let user = FleetUser(id: "1", name: "Test", email: "user+tag@sub.domain.com", photoURL: nil)
        XCTAssertEqual(user.email, "user+tag@sub.domain.com")
    }

    func testMutability() {
        var user = FleetUser(id: "1", name: "John", email: "john@test.com", photoURL: nil)
        user.name = "Jane"
        user.email = "jane@test.com"
        user.photoURL = URL(string: "https://example.com/jane.jpg")
        XCTAssertEqual(user.name, "Jane")
        XCTAssertEqual(user.email, "jane@test.com")
        XCTAssertNotNil(user.photoURL)
    }

    func testPhotoURLWithSpecialCharacters() {
        let url = URL(string: "https://example.com/photo%20image.jpg?size=large&format=webp")!
        let user = FleetUser(id: "1", name: "Test", email: "", photoURL: url)
        XCTAssertEqual(user.photoURL?.absoluteString, "https://example.com/photo%20image.jpg?size=large&format=webp")
    }
}
