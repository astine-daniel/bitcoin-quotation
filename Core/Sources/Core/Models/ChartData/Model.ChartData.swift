import Foundation

public extension Model {
    struct ChartData {
        // MARK: - Properties
        public let unit: String
        public let period: String
        public let values: [Value]
    }
}

// MARK: - ChartData.Value
public extension Model.ChartData {
    struct Value {
        // MARK: - Properties
        public let value: Decimal
        public let date: Date
    }
}
