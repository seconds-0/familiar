import SwiftUI

/// A tappable card displaying a zero state suggestion.
///
/// Features:
/// - Hover state with accent color highlight
/// - Familiar Spring animation
/// - 44pt minimum tap target for accessibility
/// - Keyboard navigation support
struct SuggestionCard: View {
    let text: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top) {
                Text(text)
                    .font(.familiarBody)
                    .foregroundStyle(Color.familiarTextPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(FamiliarSpacing.sm)
            .frame(minHeight: 44) // Accessibility: minimum tap target
            .background(
                RoundedRectangle(cornerRadius: FamiliarRadius.control)
                    .fill(isHovered ? Color.familiarAccent.opacity(0.1) : Color.familiarSurfaceElevated)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Suggestion: \(text)")
        .accessibilityHint("Paste this suggestion into the prompt")
        .onHover { hovering in
            withAnimation(.familiar) {
                isHovered = hovering
            }
        }
    }
}
