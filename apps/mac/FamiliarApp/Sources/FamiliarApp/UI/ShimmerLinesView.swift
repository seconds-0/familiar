import SwiftUI

struct ShimmerLinesView: View {
    @State private var phase: CGFloat = -1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<6, id: \.self) { idx in
                RoundedRectangle(cornerRadius: 4)
                    .fill(shimmerGradient)
                    .frame(height: 10)
                    .opacity(idx % 3 == 0 ? 0.6 : 0.8)
            }
        }
        .padding(FamiliarSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: FamiliarRadius.control)
                .fill(Color.familiarSurfaceElevated.opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: FamiliarRadius.control)
                .stroke(Color(nsColor: .separatorColor).opacity(0.25), lineWidth: 1)
        )
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                phase = 2
            }
        }
    }

    private var shimmerGradient: LinearGradient {
        let base = Color.white.opacity(0.08)
        let glow = Color.white.opacity(0.22)
        return LinearGradient(
            gradient: Gradient(stops: [
                .init(color: base, location: 0 + phase*0.0),
                .init(color: glow, location: 0.5 + phase*0.0),
                .init(color: base, location: 1 + phase*0.0)
            ]),
            startPoint: .leading, endPoint: .trailing
        )
    }
}

