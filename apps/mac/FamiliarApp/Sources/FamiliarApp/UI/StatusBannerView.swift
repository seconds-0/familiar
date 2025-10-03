import SwiftUI
import AppKit

struct StatusBannerView: View {
    enum Kind { case info, success, warning, error }
    let kind: Kind
    let summary: String
    let details: String?

    @State private var showDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
            HStack(alignment: .center, spacing: FamiliarSpacing.xs) {
                Image(systemName: iconName)
                    .foregroundStyle(iconColor)
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

    private var iconName: String {
        switch kind {
        case .info: return "info.circle.fill"
        case .success: return "checkmark.seal.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.octagon.fill"
        }
    }

    private var iconColor: Color {
        switch kind {
        case .info: return .familiarInfo
        case .success: return .familiarSuccess
        case .warning: return .familiarWarning
        case .error: return .familiarError
        }
    }
}
