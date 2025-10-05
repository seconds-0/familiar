import SwiftUI

struct ToolHistoryView: View {
    @ObservedObject var history: ToolExecutionHistory

    var body: some View {
        List(history.executions) { exec in
            DisclosureGroup {
                VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
                    Text("Input:").font(.caption.bold())
                    Text(exec.input)
                        .font(.caption.monospaced())
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                    Text("Output:").font(.caption.bold())
                    Text(exec.output)
                        .font(.caption.monospaced())
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                    HStack {
                        Label("\(exec.duration)ms", systemImage: "clock")
                        Label(exec.statusLabel, systemImage: exec.statusIcon)
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            } label: {
                HStack {
                    Image(systemName: exec.icon).foregroundStyle(exec.statusColor)
                    VStack(alignment: .leading) {
                        Text(exec.toolName).font(.headline)
                        Text(exec.timestamp, style: .relative).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(exec.statusLabel).font(.caption).foregroundStyle(exec.statusColor)
                }
            }
        }
    }
}

