import SwiftUI
import MarkdownUI

/// Familiar's custom markdown theme.
///
/// Applies the Familiar design system to markdown rendering:
/// - Typography from FamiliarTypography
/// - Colors from FamiliarColor
/// - Spacing from FamiliarSpacing
/// - Corner radius from FamiliarRadius
///
/// ## Usage
/// ```swift
/// Markdown(text)
///     .markdownTheme(.familiar)
/// ```
extension Theme {
    static let familiar = Theme()
        // Base text uses Familiar body style
        .text {
            ForegroundColor(.familiarTextPrimary)
            FontSize(15) // Matches .familiarBody
        }
        // Headings use semantic Familiar typography
        .heading1 { configuration in
            configuration.label
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(22) // Matches .familiarTitle
                }
                .markdownMargin(top: FamiliarSpacing.xs, bottom: FamiliarSpacing.xs)
        }
        .heading2 { configuration in
            configuration.label
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(18)
                }
                .markdownMargin(top: FamiliarSpacing.xs, bottom: FamiliarSpacing.xs)
        }
        .heading3 { configuration in
            configuration.label
                .markdownTextStyle {
                    FontWeight(.medium)
                    FontSize(16) // Matches .familiarHeading
                }
                .markdownMargin(top: FamiliarSpacing.xs, bottom: FamiliarSpacing.xs)
        }
        // Code blocks with Familiar mono font and surface background
        .codeBlock { configuration in
            ScrollView(.horizontal, showsIndicators: true) {
                configuration.label
                    .markdownTextStyle {
                        FontFamilyVariant(.monospaced)
                        FontSize(14)
                    }
                    .padding(FamiliarSpacing.sm)
            }
            .background(Color.familiarSurfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: FamiliarRadius.control))
            .overlay(
                RoundedRectangle(cornerRadius: FamiliarRadius.control)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.3), lineWidth: 1)
            )
            .padding(.vertical, FamiliarSpacing.xs)
        }
        // Inline code with subtle background
        .code {
            FontFamilyVariant(.monospaced)
            FontSize(14)
            BackgroundColor(Color.familiarSurfaceElevated)
        }
        // Strong (bold) emphasis
        .strong {
            FontWeight(.semibold)
        }
        // Lists with proper spacing
        .listItem { configuration in
            configuration.label
                .markdownMargin(top: FamiliarSpacing.xs, bottom: FamiliarSpacing.xs)
        }
        // Blockquotes with left accent
        .blockquote { configuration in
            HStack(alignment: .top, spacing: FamiliarSpacing.sm) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.familiarAccent)
                    .frame(width: 4)
                configuration.label
                    .markdownTextStyle {
                        ForegroundColor(.familiarTextSecondary)
                    }
            }
            .padding(.vertical, FamiliarSpacing.xs)
        }
        // Links with accent color
        .link {
            ForegroundColor(.familiarAccent)
        }
        // Horizontal rules
        .thematicBreak {
            Divider()
                .padding(.vertical, FamiliarSpacing.sm)
        }
        // Paragraph spacing
        .paragraph { configuration in
            configuration.label
                .markdownMargin(top: 0, bottom: FamiliarSpacing.xs)
        }
}
