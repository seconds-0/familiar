import SwiftUI

struct IntegrationsView: View {
    @State private var servers: [SidecarClient.MCPServer] = []
    @State private var isLoading = false

    var body: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.sm) {
            Text("Available MCP Servers").font(.familiarHeading)
            if isLoading {
                ProgressView().controlSize(.small)
            }
            HStack {
                Text("🔍 Search servers…")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.vertical, FamiliarSpacing.xs)
            ForEach(servers) { s in
                HStack {
                    VStack(alignment: .leading) {
                        Text(s.title).font(.headline)
                        Text(s.description).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Install") {}
                        .disabled(true) // Coming soon
                }
                .padding()
                .background(Color.familiarSurfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: FamiliarRadius.card))
            }
        }
        .task {
            isLoading = true
            defer { isLoading = false }
            do {
                servers = try await SidecarClient.shared.fetchMCPRegistry()
            } catch {
                servers = []
            }
        }
    }
}

