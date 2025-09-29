import Foundation

/// Token usage and cost tracking for Claude API requests
struct UsageTotals: Equatable {
    var inputTokens: Int = 0
    var outputTokens: Int = 0
    var cost: Double = 0
    var currency: String = "USD"

    var totalTokens: Int { inputTokens + outputTokens }

    var hasData: Bool {
        totalTokens > 0 || cost > 0
    }

    func adding(_ other: UsageTotals) -> UsageTotals {
        UsageTotals(
            inputTokens: inputTokens + other.inputTokens,
            outputTokens: outputTokens + other.outputTokens,
            cost: cost + other.cost,
            currency: currency
        )
    }

    init() {}

    init(inputTokens: Int, outputTokens: Int, cost: Double, currency: String) {
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.cost = cost
        self.currency = currency
    }
}

// MARK: - Parsing from API responses

extension UsageTotals {
    /// Initialize from API response dictionaries
    ///
    /// - Parameters:
    ///   - usageDict: Dictionary containing inputTokens and outputTokens
    ///   - costDict: Dictionary containing total cost and currency
    /// - Returns: UsageTotals instance, or nil if no meaningful data
    init?(usageDict: [String: Any]?, costDict: [String: Any]?) {
        guard let usageDict else { return nil }
        let input = Self.parseInt(usageDict["inputTokens"]) ?? 0
        let output = Self.parseInt(usageDict["outputTokens"]) ?? 0
        if input == 0, output == 0, costDict == nil {
            return nil
        }
        let totalCost = Self.parseDouble(costDict?["total"]) ?? 0
        let currencyValue = (costDict?["currency"] as? String) ?? "USD"
        inputTokens = input
        outputTokens = output
        cost = totalCost
        currency = currencyValue
    }

    private static func parseInt(_ value: Any?) -> Int? {
        switch value {
        case let intValue as Int:
            return intValue
        case let doubleValue as Double:
            return Int(doubleValue)
        case let number as NSNumber:
            return number.intValue
        default:
            return nil
        }
    }

    private static func parseDouble(_ value: Any?) -> Double? {
        switch value {
        case let doubleValue as Double:
            return doubleValue
        case let intValue as Int:
            return Double(intValue)
        case let number as NSNumber:
            return number.doubleValue
        default:
            return nil
        }
    }
}