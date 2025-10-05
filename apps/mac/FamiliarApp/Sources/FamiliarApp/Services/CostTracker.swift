import Foundation
import SwiftUI

final class CostTracker: ObservableObject {
    static let shared = CostTracker()

    @Published private(set) var spent: Double = 0
    @Published var budget: Double = 10.0
    @Published var alertEnabled: Bool = true
    @Published private(set) var dailyCosts: [DailyCost] = []

    struct DailyCost: Identifiable {
        let id = UUID()
        let date: Date
        let amount: Double
    }

    private let calendar = Calendar.current
    private let store = UserDefaults.standard
    private let monthKey: String

    private init() {
        let monthId = Self.currentMonthId()
        monthKey = "costs_\(monthId)"
        load()
    }

    func record(amount: Double) {
        guard amount > 0 else { return }
        // Reset if month changed
        let current = Self.currentMonthId()
        if monthKey != "costs_\(current)" {
            // New month
            store.removeObject(forKey: monthKey)
            spent = 0
            dailyCosts = []
        }
        spent += amount
        // Append to today
        if let last = dailyCosts.last, calendar.isDateInToday(last.date) {
            let updated = DailyCost(date: last.date, amount: last.amount + amount)
            dailyCosts[dailyCosts.count - 1] = updated
        } else {
            dailyCosts.append(DailyCost(date: Date(), amount: amount))
        }
        persist()
    }

    var percentUsed: Double { guard budget > 0 else { return 0 }; return min(spent / budget, 1.0) }
    var isNearLimit: Bool { percentUsed >= 0.8 }

    private func persist() {
        let payload: [String: Any] = [
            "spent": spent,
            "budget": budget,
            "alertEnabled": alertEnabled,
            "daily": dailyCosts.map { ["date": $0.date.timeIntervalSince1970, "amount": $0.amount] }
        ]
        store.set(payload, forKey: monthKey)
    }

    private func load() {
        guard let obj = store.object(forKey: monthKey) as? [String: Any] else { return }
        spent = obj["spent"] as? Double ?? 0
        budget = obj["budget"] as? Double ?? 10.0
        alertEnabled = obj["alertEnabled"] as? Bool ?? true
        if let daily = obj["daily"] as? [[String: Any]] {
            dailyCosts = daily.compactMap { item in
                guard let ts = item["date"] as? Double, let amt = item["amount"] as? Double else { return nil }
                return DailyCost(date: Date(timeIntervalSince1970: ts), amount: amt)
            }
        }
    }

    private static func currentMonthId() -> String {
        let comps = Calendar.current.dateComponents([.year, .month], from: Date())
        let y = comps.year ?? 0
        let m = comps.month ?? 0
        return String(format: "%04d-%02d", y, m)
    }
}

