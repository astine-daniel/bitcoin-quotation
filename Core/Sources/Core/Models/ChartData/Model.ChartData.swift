import Foundation

public extension Model {
    struct ChartData {
        // MARK: - Properties
        public let unit: String
        public let period: String
        public let values: [Value]

        // MARK: - Initialization
        public init(unit: String, period: String, values: [Value]) {
            self.unit = unit
            self.period = period
            self.values = values
        }
    }
}

// MARK: - ChartData.Value
public extension Model.ChartData {
    struct Value {
        // MARK: - Properties
        public let value: Decimal
        public let date: Date

        // MARK: - Initialization
        public init(value: Decimal, date: Date) {
            self.value = value
            self.date = date
        }
    }
}
