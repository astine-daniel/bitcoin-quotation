import Combine
import Common

public protocol BlockchainAPIServiceProtocol {
    func fetchMarketPriceChartData(ofLast days: Int) -> AnyPublisher<ResponseModel.ChartData, NetworkingError>
    func fetchStats() -> AnyPublisher<ResponseModel.Stats, NetworkingError>
}

public extension BlockchainAPIServiceProtocol {
    func fetchMarketPriceChartData() -> AnyPublisher<ResponseModel.ChartData, NetworkingError> {
        fetchMarketPriceChartData(ofLast: 30)
    }
}
