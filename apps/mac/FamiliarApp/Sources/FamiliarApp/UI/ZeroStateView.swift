import SwiftUI

/// Zero state view shown when transcript is empty.
///
/// Displays AI-generated contextual suggestions to inspire user action.
/// Features:
/// - Loading state with shimmer placeholders
/// - 4 AI-generated suggestions
/// - Graceful error handling with fallback text
/// - Familiar Spring animations
struct ZeroStateView: View {
    let onSuggestionTap: (String) -> Void
    let fetchSuggestions: () async -> [String]

    @State private var loadingState: LoadingState = .loading
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    enum LoadingState {
        case loading
        case loaded([String])
        case error
    }

    var body: some View {
        VStack(spacing: FamiliarSpacing.md) {
            Text("What can I help you with today?")
                .font(.familiarTitle)
                .foregroundStyle(Color.familiarTextPrimary)
                .padding(.top, FamiliarSpacing.xl)

            VStack(spacing: FamiliarSpacing.sm) {
                switch loadingState {
                case .loading:
                    ForEach(0..<4, id: \.self) { _ in
                        ShimmerCard()
                    }

                case .loaded(let suggestions):
                    ForEach(Array(suggestions.enumerated()), id: \.offset) { _, suggestion in
                        SuggestionCard(text: suggestion) {
                            onSuggestionTap(suggestion)
                        }
                        .transition(
                            reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.95))
                        )
                    }

                case .error:
                    Text("Type what you need, and I'll help you with it")
                        .font(.familiarBody)
                        .foregroundStyle(Color.familiarTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(FamiliarSpacing.md)
                }
            }

            Text("Or just type what you need...")
                .font(.familiarCaption)
                .foregroundStyle(Color.familiarTextSecondary)
                .padding(.bottom, FamiliarSpacing.md)
        }
        .padding(FamiliarSpacing.lg)
        .task {
            await loadSuggestions()
        }
    }

    private func loadSuggestions() async {
        let suggestions = await fetchSuggestions()

        withAnimation(.familiar) {
            if suggestions.isEmpty {
                loadingState = .error
            } else {
                loadingState = .loaded(suggestions)
            }
        }
    }
}
