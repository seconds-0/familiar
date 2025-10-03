import SwiftUI

/// Custom menu bar icon that subtly animates when the agent is working
/// and switches color when idle, per design guidelines.
struct MenuBarIconView: View {
    @ObservedObject private var activity = AgentActivityCenter.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "sparkles")
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(iconTint)

            if activity.isWorking && !reduceMotion {
                BreathingDotView()
                    .scaleEffect(0.6)
                    .offset(x: 5.5, y: 4.5)
                    .transition(.opacity.animation(.familiar))
            }
        }
        .accessibilityLabel(activity.isWorking ? "Working…" : "Ready")
        .accessibilityAddTraits(.updatesFrequently)
    }

    private var iconTint: Color {
        activity.isWorking ? .familiarAccent : .familiarSuccess
    }
}

