import SwiftUI

/// Familiar's corner radius system.
///
/// Two primary values create visual consistency:
/// - Smaller UI controls use 8pt for subtlety
/// - Larger containers use 16pt for presence
///
/// ## Usage
/// ```swift
/// RoundedRectangle(cornerRadius: FamiliarRadius.control)
/// RoundedRectangle(cornerRadius: FamiliarRadius.card)
/// ```
enum FamiliarRadius {
    /// Control: 8pt - Buttons, text fields, small UI elements
    static let control: CGFloat = 8

    /// Card: 16pt - Panels, sheets, containers, larger surfaces
    static let card: CGFloat = 16

    /// Field: 12pt - Text inputs, prompt composer
    static let field: CGFloat = 12
}
