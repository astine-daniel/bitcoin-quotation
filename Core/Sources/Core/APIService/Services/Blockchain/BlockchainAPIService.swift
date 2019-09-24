import Combine
import Common

public struct BlockchainAPIService {
    // MARK: - Properties
    private let apiService: APIServiceProtocol

    // MARK: - Initialization
    public init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
}

// MARK: - BlockchainAPIServiceProtocol extension
extension BlockchainAPIService: BlockchainAPIServiceProtocol {
    public func fetchMarketPriceChartData(ofLast days: Int) -> AnyPublisher<ResponseModel.ChartData, NetworkingError> {
        apiService.request(resource: .marketPriceChartData(ofLast: days))
    }

    public func fetchStats() -> AnyPublisher<ResponseModel.Stats, NetworkingError> {
        apiService.request(resource: .stats())
    }
}

// MARK: - Private extension
private extension APIServiceProtocol {
    @discardableResult
    func request<T: Decodable>(resource: BlockchainResource) -> AnyPublisher<T, NetworkingError> {
        request(resource)
    }
}
