import SwiftUI

/// Familiar's motion system - The Familiar Spring.
///
/// A signature spring animation that feels responsive and natural.
/// The key parameters create personality:
/// - response: 0.3s (quick but not rushed)
/// - dampingFraction: 0.7 (slight bounce, feels alive)
///
/// ## Usage
/// ```swift
/// .animation(.familiar, value: someState)
/// .animation(.familiarInteractive, value: isPressed)
/// .animation(.familiarContextual, value: isPresented)
/// ```
extension Animation {
    /// The Familiar Spring - Our signature motion
    ///
    /// Use this as the default animation for most state changes.
    /// It creates a consistent, delightful feel throughout the app.
    static let familiar = Animation.spring(
        response: 0.3,
        dampingFraction: 0.7
    )

    /// Interactive - For direct user input (button presses, taps)
    ///
    /// Slightly faster (200ms) for immediate feedback to user actions.
    static let familiarInteractive: Animation = {
        let targetDuration: Double = 0.2
        let baseResponse: Double = 0.3
        let speedMultiplier = baseResponse / targetDuration
        return familiar.speed(speedMultiplier)
    }()

    /// Contextual - For sheets, overlays, contextual UI
    ///
    /// Medium speed (250ms) for non-blocking secondary content.
    static let familiarContextual: Animation = {
        let targetDuration: Double = 0.25
        let baseResponse: Double = 0.3
        let speedMultiplier = baseResponse / targetDuration
        return familiar.speed(speedMultiplier)
    }()
}
