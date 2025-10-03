import XCTest
import SwiftUI
@testable import FamiliarApp

final class DesignTokensTests: XCTestCase {
    func testSpacingValues() {
        XCTAssertEqual(FamiliarSpacing.xs, 8)
        XCTAssertEqual(FamiliarSpacing.sm, 16)
        XCTAssertEqual(FamiliarSpacing.md, 24)
        XCTAssertEqual(FamiliarSpacing.lg, 32)
        XCTAssertEqual(FamiliarSpacing.xl, 48)
    }

    func testRadiusValues() {
        XCTAssertEqual(FamiliarRadius.control, 8)
        XCTAssertEqual(FamiliarRadius.field, 12)
        XCTAssertEqual(FamiliarRadius.card, 16)
    }
}

