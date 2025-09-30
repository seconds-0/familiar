import SwiftUI

/// Familiar's typography system.
///
/// These font styles create a clear hierarchy while maintaining readability.
/// All text should use these semantic names rather than direct font specifications.
///
/// ## Usage
/// ```swift
/// Text("Hello")
///     .font(.familiarTitle)
/// Text("Section")
///     .font(.familiarHeading)
/// Text("Body text")
///     .font(.familiarBody)
/// ```
extension Font {
    /// Title: Large, semibold - Page titles, major headings
    static let familiarTitle = Font.system(.title2, design: .default, weight: .semibold)

    /// Heading: Medium weight - Section headings, emphasis
    static let familiarHeading = Font.system(.headline, design: .default, weight: .medium)

    /// Body: Regular - Primary content, most text
    static let familiarBody = Font.system(.body, design: .default, weight: .regular)

    /// Caption: Small, regular - Secondary information, hints
    static let familiarCaption = Font.system(.caption, design: .default, weight: .regular)

    /// Mono: Monospaced - Code, technical content, transcripts
    static let familiarMono = Font.system(.body, design: .monospaced, weight: .regular)
}
