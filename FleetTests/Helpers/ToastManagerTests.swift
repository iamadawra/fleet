import XCTest
@testable import Fleet

@MainActor
final class ToastManagerTests: XCTestCase {

    var manager: ToastManager!

    override func setUp() {
        super.setUp()
        manager = ToastManager()
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialStateHasNoToast() {
        XCTAssertNil(manager.currentToast)
    }

    // MARK: - Show Methods

    func testShowSuccess() {
        manager.showSuccess("Saved!")
        XCTAssertNotNil(manager.currentToast)
        XCTAssertEqual(manager.currentToast?.type, .success)
        XCTAssertEqual(manager.currentToast?.message, "Saved!")
    }

    func testShowError() {
        manager.showError("Something went wrong")
        XCTAssertNotNil(manager.currentToast)
        XCTAssertEqual(manager.currentToast?.type, .error)
        XCTAssertEqual(manager.currentToast?.message, "Something went wrong")
    }

    func testShowWarning() {
        manager.showWarning("Check your input")
        XCTAssertNotNil(manager.currentToast)
        XCTAssertEqual(manager.currentToast?.type, .warning)
        XCTAssertEqual(manager.currentToast?.message, "Check your input")
    }

    func testShowGeneric() {
        manager.show("Hello", type: .success, duration: 5.0)
        XCTAssertNotNil(manager.currentToast)
        XCTAssertEqual(manager.currentToast?.message, "Hello")
    }

    // MARK: - Toast Replacement

    func testNewToastReplacesExisting() {
        manager.showSuccess("First")
        let firstId = manager.currentToast?.id
        manager.showError("Second")
        XCTAssertNotEqual(manager.currentToast?.id, firstId)
        XCTAssertEqual(manager.currentToast?.type, .error)
        XCTAssertEqual(manager.currentToast?.message, "Second")
    }

    // MARK: - Empty Messages

    func testEmptyMessage() {
        manager.showSuccess("")
        XCTAssertNotNil(manager.currentToast)
        XCTAssertEqual(manager.currentToast?.message, "")
    }

    // MARK: - Long Messages

    func testLongMessage() {
        let longMsg = String(repeating: "A", count: 10_000)
        manager.showWarning(longMsg)
        XCTAssertEqual(manager.currentToast?.message.count, 10_000)
    }

    // MARK: - Unicode Messages

    func testUnicodeMessage() {
        manager.showSuccess("\u{2705} Vehicle added!")
        XCTAssertTrue(manager.currentToast?.message.contains("\u{2705}") ?? false)
    }

    // MARK: - Toast Model

    func testToastIdentifiable() {
        let toast = Toast(type: .success, message: "Test")
        XCTAssertNotNil(toast.id)
    }

    func testToastEqualityById() {
        let toast1 = Toast(type: .success, message: "A")
        let toast2 = Toast(type: .success, message: "A")
        XCTAssertNotEqual(toast1, toast2, "Different toasts should not be equal")
    }

    // MARK: - Toast Type Properties

    func testSuccessTypeProperties() {
        let type = Toast.ToastType.success
        XCTAssertEqual(type.icon, "checkmark.circle.fill")
    }

    func testErrorTypeProperties() {
        let type = Toast.ToastType.error
        XCTAssertEqual(type.icon, "xmark.circle.fill")
    }

    func testWarningTypeProperties() {
        let type = Toast.ToastType.warning
        XCTAssertEqual(type.icon, "exclamationmark.triangle.fill")
    }
}
