import SwiftUI

/// A shimmer loading placeholder for suggestion cards.
///
/// Shows a subtle pulsing animation while AI suggestions are being generated.
/// Respects reduced motion accessibility preference.
struct ShimmerCard: View {
    @State private var opacity: Double = 0.3
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        RoundedRectangle(cornerRadius: FamiliarRadius.control)
            .fill(Color.familiarSurfaceElevated.opacity(opacity))
            .frame(height: 44)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(
                    .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
                ) {
                    opacity = 0.6
                }
            }
    }
}
