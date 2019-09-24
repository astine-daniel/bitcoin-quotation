import Foundation

public extension ResponseModel {
    struct Stats {
        let date: Date
        let marketPriceInUSD: Decimal
    }
}

// MARK: - Stats Decodable extension
extension ResponseModel.Stats: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let marketPriceInUSD: Decimal = try container.decode(Decimal.self, forKey: .marketPriceInUSD)

        let dateTimestamp: TimeInterval = try container.decode(TimeInterval.self, forKey: .timestamp)
        let date = Date(timeIntervalSince1970: dateTimestamp / 1_000)

        self.init(date: date, marketPriceInUSD: marketPriceInUSD)
    }
}

private extension ResponseModel.Stats {
    enum CodingKeys: String, CodingKey {
        case timestamp = "timestamp"
        case marketPriceInUSD = "market_price_usd"
    }
}
