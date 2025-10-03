import XCTest
@testable import FamiliarApp

final class AgentActivityCenterTests: XCTestCase {
    var activityCenter: AgentActivityCenter!

    @MainActor
    override func setUp() {
        super.setUp()
        activityCenter = AgentActivityCenter.shared
        // Reset state before each test
        activityCenter.endActivity(.streaming)
        activityCenter.endActivity(.permission)
    }

    @MainActor
    func testInitialStateIsNotWorking() {
        XCTAssertFalse(activityCenter.isWorking, "Activity center should start in idle state")
    }

    @MainActor
    func testBeginActivitySetsWorkingState() {
        activityCenter.beginActivity(.streaming)
        XCTAssertTrue(activityCenter.isWorking, "Should be working after beginning activity")
    }

    @MainActor
    func testEndActivityClearsWorkingState() {
        activityCenter.beginActivity(.streaming)
        activityCenter.endActivity(.streaming)
        XCTAssertFalse(activityCenter.isWorking, "Should not be working after ending activity")
    }

    @MainActor
    func testMultipleActivitiesKeepWorkingState() {
        activityCenter.beginActivity(.streaming)
        activityCenter.beginActivity(.permission)

        XCTAssertTrue(activityCenter.isWorking, "Should be working with multiple activities")

        activityCenter.endActivity(.streaming)
        XCTAssertTrue(activityCenter.isWorking, "Should still be working with one activity remaining")

        activityCenter.endActivity(.permission)
        XCTAssertFalse(activityCenter.isWorking, "Should not be working after all activities end")
    }

    @MainActor
    func testOverlappingActivitiesOfSameType() {
        // Simulate overlapping streaming activities (e.g., rapid start/stop)
        activityCenter.beginActivity(.streaming)
        activityCenter.beginActivity(.streaming)

        activityCenter.endActivity(.streaming)
        XCTAssertTrue(activityCenter.isWorking, "Should still be working with one streaming activity remaining")

        activityCenter.endActivity(.streaming)
        XCTAssertFalse(activityCenter.isWorking, "Should not be working after all streaming activities end")
    }

    @MainActor
    func testEndingActivityMoreTimesThanBegun() {
        // Edge case: end activity without beginning it
        activityCenter.beginActivity(.streaming)
        activityCenter.endActivity(.streaming)
        activityCenter.endActivity(.streaming) // Extra end call

        XCTAssertFalse(activityCenter.isWorking, "Should handle extra end calls gracefully")

        // Should still work correctly after
        activityCenter.beginActivity(.permission)
        XCTAssertTrue(activityCenter.isWorking, "Should work correctly after extra end calls")
    }

    @MainActor
    func testMixedActivities() {
        activityCenter.beginActivity(.streaming)
        activityCenter.beginActivity(.permission)
        activityCenter.beginActivity(.streaming)

        activityCenter.endActivity(.permission)
        XCTAssertTrue(activityCenter.isWorking, "Should still have streaming activities")

        activityCenter.endActivity(.streaming)
        XCTAssertTrue(activityCenter.isWorking, "Should still have one streaming activity")

        activityCenter.endActivity(.streaming)
        XCTAssertFalse(activityCenter.isWorking, "All activities ended")
    }
}
