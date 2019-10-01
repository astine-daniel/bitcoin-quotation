import Combine

public final class BlockchainRepository {
    // MARK: - Properties
    private let service: BlockchainAPIServiceProtocol

    // MARK: - Initialization
    public init(service: BlockchainAPIServiceProtocol = BlockchainAPIService()) {
        self.service = service
    }
}

extension BlockchainRepository: BlockchainRepositoryProtocol {
    public func fetchStats() -> AnyPublisher<Model.Stats, Error> {
        service.fetchStats().map {
            Model.Stats(date: $0.date, marketPriceInUSD: $0.marketPriceInUSD)
        }
        .mapError { $0 as Error }
        .eraseToAnyPublisher()
    }

    public func fetchMarketPriceChartData(ofLast days: Int) -> AnyPublisher<Model.ChartData, Error> {
        service.fetchMarketPriceChartData(ofLast: days).map {
            Model.ChartData(
                unit: $0.unit,
                period: $0.period,
                values: $0.values.map { value in
                    Model.ChartData.Value(value: value.value, date: value.date)
                }
            )
        }
        .mapError { $0 as Error }
        .eraseToAnyPublisher()
    }
}
