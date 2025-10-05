import SwiftUI

struct CostDashboardView: View {
    @ObservedObject var tracker: CostTracker

    var body: some View {
        VStack(alignment: .leading, spacing: FamiliarSpacing.sm) {
            HStack {
                Text("Budget").font(.familiarHeading)
                Spacer()
                Text(String(format: "$%.2f / $%.2f", tracker.spent, tracker.budget))
                    .foregroundStyle(tracker.isNearLimit ? .orange : .secondary)
                    .font(.familiarBody)
            }

            ProgressView(value: tracker.percentUsed)
                .tint(tracker.isNearLimit ? .orange : .accentColor)

            VStack(alignment: .leading, spacing: FamiliarSpacing.xs) {
                ForEach(tracker.dailyCosts) { day in
                    HStack {
                        Text(day.date, style: .date).font(.caption)
                        Spacer()
                        Text(String(format: "$%.2f", day.amount)).font(.caption.monospacedDigit())
                    }
                }
            }

            HStack(spacing: FamiliarSpacing.xs) {
                Text("Monthly Budget")
                TextField("$", value: $tracker.budget, format: .number)
                    .frame(width: 80)
                    .textFieldStyle(.roundedBorder)
            }

            Toggle("Alert at 80%", isOn: $tracker.alertEnabled)
                .toggleStyle(.switch)
        }
        .padding(FamiliarSpacing.sm)
        .background(Color.familiarSurfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: FamiliarRadius.card))
    }
}

