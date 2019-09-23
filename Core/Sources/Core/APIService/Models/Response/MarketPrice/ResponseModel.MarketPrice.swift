import Foundation

public extension ResponseModel {
    struct MarketPrice {
        let unit: String
        let period: String
        let values: [Value]
    }
}

// MARK: - MarketPrice Decodable extension
extension ResponseModel.MarketPrice: Decodable { }

// MARK: - MarketPrice.Value
public extension ResponseModel.MarketPrice {
    struct Value {
        let value: Decimal
        let date: Date
    }
}

// MARK: - MarketPrice.Value Decodable extension
extension ResponseModel.MarketPrice.Value: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let value: Decimal = try container.decode(Decimal.self, forKey: .value)

        let dateTimestamp: TimeInterval = try container.decode(TimeInterval.self, forKey: .dateTimestamp)
        let date = Date(timeIntervalSince1970: dateTimestamp)

        self.init(value: value, date: date)
    }
}

private extension ResponseModel.MarketPrice.Value {
    enum CodingKeys: String, CodingKey {
        case value = "y"
        case dateTimestamp = "x"
    }
}
