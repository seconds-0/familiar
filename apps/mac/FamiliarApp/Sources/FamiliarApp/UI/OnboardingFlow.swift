import SwiftUI

struct OnboardingFlow: View {
    enum Step: Int { case welcome = 0, authChoice = 1, workspace = 2 }

    @Binding var isPresented: Bool
    @State private var step: Step = .welcome
    @ObservedObject var settingsVM: SettingsViewModel

    var body: some View {
        VStack(spacing: FamiliarSpacing.md) {
            switch step {
            case .welcome:
                VStack(spacing: FamiliarSpacing.sm) {
                    Text("Welcome to Familiar!")
                        .font(.familiarTitle)
                    Text("Let's get you set up…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Image(systemName: "command")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                }
            case .authChoice:
                VStack(alignment: .leading, spacing: FamiliarSpacing.sm) {
                    Text("How would you like to connect?")
                        .font(.familiarHeading)
                    HStack(spacing: FamiliarSpacing.sm) {
                        AuthCard(
                            title: "Claude.ai Login",
                            subtitle: "No API key needed",
                            recommended: true,
                            actionTitle: settingsVM.hasClaudeSession ? "Signed In" : "Sign In",
                            action: settingsVM.signInClaude
                        )
                        AuthCard(
                            title: "API Key",
                            subtitle: "For advanced users",
                            recommended: false,
                            actionTitle: "Enter Key",
                            action: { settingsVM.selectedAuthMode = .apiKey }
                        )
                    }
                }
            case .workspace:
                VStack(alignment: .leading, spacing: FamiliarSpacing.sm) {
                    Text("Choose your workspace")
                        .font(.familiarHeading)
                    HStack(spacing: FamiliarSpacing.xs) {
                        TextField("/path/to/workspace", text: $settingsVM.workspacePath)
                            .textFieldStyle(.roundedBorder)
                        Button("Browse…") {
                            if let path = settingsVM.selectWorkspace() {
                                settingsVM.workspacePath = path
                            }
                        }
                    }
                    Text("Familiar will work within this directory.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                if step != .welcome { Button("Back") { previous() } }
                Spacer()
                Button(step == .workspace ? "Finish" : "Continue →") {
                    if step == .workspace { complete() } else { next() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(FamiliarSpacing.md)
        .frame(width: 520)
    }

    private func next() { step = Step(rawValue: min(step.rawValue + 1, Step.workspace.rawValue)) ?? .workspace }
    private func previous() { step = Step(rawValue: max(step.rawValue - 1, Step.welcome.rawValue)) ?? .welcome }
    private func complete() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        isPresented = false
    }
}

private struct AuthCard: View {
    let title: String
    let subtitle: String
    let recommended: Bool
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
            HStack {
                Text(title).font(.headline)
                if recommended {
                    Text("Recommended")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            Spacer(minLength: 0)
            Button(actionTitle, action: action)
        }
        .padding(FamiliarSpacing.sm)
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(Color.familiarSurfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: FamiliarRadius.card))
    }
}

