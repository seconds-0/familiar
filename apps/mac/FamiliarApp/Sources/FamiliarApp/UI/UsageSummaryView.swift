import SwiftUI

struct UsageSummaryView: View {
    let totals: UsageTotals
    let last: UsageTotals?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                Label("Session", systemImage: "sparkles")
                Text("\(totals.totalTokens) tokens")
                if totals.cost > 0 {
                    Text(currencyString(for: totals.cost, currency: totals.currency))
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            if let last, last.hasData {
                HStack(spacing: 12) {
                    Label("Last", systemImage: "clock.arrow.circlepath")
                    Text("\(last.totalTokens) tokens")
                    if last.cost > 0 {
                        Text(currencyString(for: last.cost, currency: last.currency))
                    }
                }
                .font(.footnote)
                .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func currencyString(for amount: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = amount < 0.01 ? 4 : 2
        return formatter.string(from: NSNumber(value: amount)) ?? String(format: "$%.2f", amount)
    }
}
