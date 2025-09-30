import SwiftUI

/// A subtle breathing dot progress indicator.
///
/// Replaces the spinning ProgressView with a more zen, less distracting indicator.
/// The dot gently pulses with opacity changes rather than spinning.
///
/// ## Usage
/// ```swift
/// if isLoading {
///     BreathingDotView()
/// }
/// ```
struct BreathingDotView: View {
    @State private var opacity: Double = 0.3
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Circle()
            .fill(Color.familiarAccent)
            .frame(width: FamiliarSpacing.xs, height: FamiliarSpacing.xs)
            .opacity(reduceMotion ? 1.0 : opacity)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    opacity = 1.0
                }
            }
            .accessibilityLabel("Loading")
            .accessibilityAddTraits(.updatesFrequently)
    }
}
