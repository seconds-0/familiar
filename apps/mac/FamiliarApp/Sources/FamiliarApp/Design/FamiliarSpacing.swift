import SwiftUI

/// Familiar's spacing system based on an 8pt rhythm.
///
/// These values create a consistent visual hierarchy and rhythm throughout the app.
/// All spacing should use these tokens rather than hardcoded values.
///
/// ## Usage
/// ```swift
/// VStack(spacing: FamiliarSpacing.md) {
///     // content
/// }
/// .padding(FamiliarSpacing.lg)
/// ```
enum FamiliarSpacing {
    /// Extra small: 8pt - Tight inline elements, minimal separation
    static let xs: CGFloat = 8

    /// Small: 16pt - Related components that belong together
    static let sm: CGFloat = 16

    /// Medium: 24pt - Component groups with clear separation
    static let md: CGFloat = 24

    /// Large: 32pt - Major sections within a view
    static let lg: CGFloat = 32

    /// Extra large: 48pt - Primary regions, major visual breaks
    static let xl: CGFloat = 48
}
