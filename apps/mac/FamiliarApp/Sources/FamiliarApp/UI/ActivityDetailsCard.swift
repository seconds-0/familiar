import SwiftUI

struct ActivityDetailsCard: View {
    let log: [String]
    let phase: FamiliarViewModel.Phase?

    var body: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
            ForEach(Array(log.enumerated()), id: \.offset) { idx, item in
                HStack(alignment: .center, spacing: FamiliarSpacing.xs) {
                    Image(systemName: bulletIcon(for: idx))
                        .imageScale(.small)
                        .foregroundStyle(.secondary)
                    Text(item)
                        .font(.familiarCaption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(FamiliarSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: FamiliarRadius.card)
                .fill(Color.familiarSurfaceElevated.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: FamiliarRadius.card)
                .stroke(Color(nsColor: .separatorColor).opacity(0.25), lineWidth: 1)
        )
    }

    private func bulletIcon(for idx: Int) -> String {
        // Give the latest item a different bullet
        return idx == log.count - 1 ? "smallcircle.filled.circle" : "circle"
    }
}

