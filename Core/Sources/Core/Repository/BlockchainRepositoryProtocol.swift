import Combine

public protocol BlockchainRepositoryProtocol {
    func fetchMarketPriceChartData(ofLast days: Int) -> AnyPublisher<Model.ChartData, Error>
    func fetchStats() -> AnyPublisher<Model.Stats, Error>
}
