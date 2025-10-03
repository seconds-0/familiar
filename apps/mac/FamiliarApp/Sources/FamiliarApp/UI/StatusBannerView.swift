import SwiftUI
import AppKit

struct StatusBannerView: View {
    let summary: String
    let details: String?

    @State private var showDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
            HStack(alignment: .center, spacing: FamiliarSpacing.xs) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color.familiarWarning)
                Text(summary)
                    .font(.familiarBody)
                    .foregroundStyle(Color.familiarTextPrimary)
                Spacer()
                if details != nil {
                    Button(showDetails ? "Hide details" : "Show details") {
                        withAnimation(.familiarInteractive) { showDetails.toggle() }
                    }
                    .buttonStyle(.link)
                }
            }

            if showDetails, let details {
                ScrollView(.vertical, showsIndicators: true) {
                    Text(details)
                        .font(.familiarMono)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(.vertical, 4)
                }
                .frame(minHeight: 60, idealHeight: 100, maxHeight: 160)
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: FamiliarRadius.control))
                .overlay(
                    RoundedRectangle(cornerRadius: FamiliarRadius.control)
                        .stroke(Color(nsColor: .separatorColor).opacity(0.3), lineWidth: 1)
                )

                HStack {
                    Spacer()
                    Button("Copy details") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(details, forType: .string)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(FamiliarSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: FamiliarRadius.card)
                .fill(Color.familiarSurfaceElevated)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
