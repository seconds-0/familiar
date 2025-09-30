import SwiftUI

/// Familiar's semantic color system.
///
/// Uses system colors to automatically adapt to light/dark mode and accessibility settings.
/// These semantic names describe purpose, not appearance.
///
/// ## Usage
/// ```swift
/// Text("Hello")
///     .foregroundStyle(.familiarTextPrimary)
/// RoundedRectangle(cornerRadius: 8)
///     .fill(Color.familiarBackground)
/// ```
extension Color {
    // MARK: - Foundation Colors

    /// Background: Primary window/view background
    static let familiarBackground = Color(nsColor: .windowBackgroundColor)

    /// Surface Elevated: Raised surfaces like cards, sheets
    static let familiarSurfaceElevated = Color(nsColor: .controlBackgroundColor)

    /// Text Primary: Main content text
    static let familiarTextPrimary = Color.primary

    /// Text Secondary: Supporting text, less emphasis
    static let familiarTextSecondary = Color.secondary

    // MARK: - Semantic Colors

    /// Success: Positive outcomes, confirmations
    static let familiarSuccess = Color.green

    /// Warning: Cautions, important notices
    static let familiarWarning = Color.orange

    /// Error: Problems, failures
    static let familiarError = Color.red

    /// Info: Informational messages
    static let familiarInfo = Color.blue

    // MARK: - Accent

    /// Accent: Interactive elements, primary actions
    static let familiarAccent = Color.accentColor
}
