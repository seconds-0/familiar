import SwiftUI

struct SettingsView: View {
    @AppStorage("anthropicApiKey") private var apiKey: String = ""

    var body: some View {
        Form {
            SecureField("Anthropic API Key", text: $apiKey)
            Button("Test Connection", action: testConnection)
        }
        .padding(24)
        .frame(width: 420)
    }

    private func testConnection() {
        Task {
            do {
                try await SidecarClient.shared.healthCheck()
            } catch {
                NSLog("Health check failed: \(error.localizedDescription)")
            }
        }
    }
}
