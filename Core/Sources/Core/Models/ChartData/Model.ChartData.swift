import Foundation

public extension Model {
    struct ChartData {
        let unit: String
        let period: String
        let values: [Value]
    }
}

// MARK: - ChartData.Value
public extension Model.ChartData {
    struct Value {
        let value: Decimal
        let date: Date
    }
}
