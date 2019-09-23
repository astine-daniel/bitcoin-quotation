import Foundation

public extension ResponseModel {
    struct ChartData {
        let unit: String
        let period: String
        let values: [Value]
    }
}

// MARK: - ChartData Decodable extension
extension ResponseModel.ChartData: Decodable { }

// MARK: - ChartData.Value
public extension ResponseModel.ChartData {
    struct Value {
        let value: Decimal
        let date: Date
    }
}

// MARK: - ChartData.Value Decodable extension
extension ResponseModel.ChartData.Value: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let value: Decimal = try container.decode(Decimal.self, forKey: .value)

        let dateTimestamp: TimeInterval = try container.decode(TimeInterval.self, forKey: .dateTimestamp)
        let date = Date(timeIntervalSince1970: dateTimestamp)

        self.init(value: value, date: date)
    }
}

private extension ResponseModel.ChartData.Value {
    enum CodingKeys: String, CodingKey {
        case value = "y"
        case dateTimestamp = "x"
    }
}
