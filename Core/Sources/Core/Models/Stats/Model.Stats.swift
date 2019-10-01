import Foundation

public extension Model {
    struct Stats {
        // MARK: - Properties
        public let date: Date
        public let marketPriceInUSD: Decimal

        // MARK: - Initialization
        public init(date: Date, marketPriceInUSD: Decimal) {
            self.date = date
            self.marketPriceInUSD = marketPriceInUSD
        }
    }
}
