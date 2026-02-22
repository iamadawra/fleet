import XCTest
import SwiftUI
@testable import Fleet

final class LoadingViewTests: XCTestCase {

    // MARK: - LaunchLoadingView One-Liners

    func testOneLinersCountIsFifteen() {
        let oneLiners = LaunchLoadingView.oneLiners
        XCTAssertEqual(oneLiners.count, 15, "There should be exactly 15 one-liners")
    }

    func testOneLinersAreAllNonEmpty() {
        for (index, line) in LaunchLoadingView.oneLiners.enumerated() {
            XCTAssertFalse(line.isEmpty, "One-liner at index \(index) should not be empty")
        }
    }

    func testOneLinersAreAllUnique() {
        let uniqueLines = Set(LaunchLoadingView.oneLiners)
        XCTAssertEqual(
            uniqueLines.count,
            LaunchLoadingView.oneLiners.count,
            "All one-liners should be unique"
        )
    }

    func testOneLinersAllEndWithEllipsis() {
        for (index, line) in LaunchLoadingView.oneLiners.enumerated() {
            XCTAssertTrue(
                line.hasSuffix("..."),
                "One-liner at index \(index) (\"\(line)\") should end with '...'"
            )
        }
    }

    // MARK: - LaunchPhase Enum

    func testLaunchPhaseHasAllCases() {
        let splash = FleetApp.LaunchPhase.splash
        let skeleton = FleetApp.LaunchPhase.skeleton
        let ready = FleetApp.LaunchPhase.ready

        XCTAssertNotEqual(splash, skeleton)
        XCTAssertNotEqual(skeleton, ready)
        XCTAssertNotEqual(splash, ready)
    }

    func testLaunchPhaseEquatable() {
        XCTAssertEqual(FleetApp.LaunchPhase.splash, FleetApp.LaunchPhase.splash)
        XCTAssertEqual(FleetApp.LaunchPhase.skeleton, FleetApp.LaunchPhase.skeleton)
        XCTAssertEqual(FleetApp.LaunchPhase.ready, FleetApp.LaunchPhase.ready)
    }

    // MARK: - SkeletonBone Default Properties

    func testSkeletonBoneDefaultHeight() {
        let bone = SkeletonBone()
        XCTAssertEqual(bone.height, 14)
    }

    func testSkeletonBoneDefaultRadius() {
        let bone = SkeletonBone()
        XCTAssertEqual(bone.radius, 8)
    }

    func testSkeletonBoneDefaultWidthIsNil() {
        let bone = SkeletonBone()
        XCTAssertNil(bone.width)
    }

    func testSkeletonBoneCustomProperties() {
        let bone = SkeletonBone(width: 200, height: 24, radius: 12)
        XCTAssertEqual(bone.width, 200)
        XCTAssertEqual(bone.height, 24)
        XCTAssertEqual(bone.radius, 12)
    }

    // MARK: - View Instantiation

    func testLaunchLoadingViewInstantiates() {
        let view = LaunchLoadingView()
        XCTAssertNotNil(view)
    }

    func testSkeletonLoadingViewInstantiates() {
        let view = SkeletonLoadingView()
        XCTAssertNotNil(view)
    }

    func testSkeletonBoneViewInstantiates() {
        let view = SkeletonBone(width: 100, height: 16, radius: 8)
        XCTAssertNotNil(view)
    }
}
