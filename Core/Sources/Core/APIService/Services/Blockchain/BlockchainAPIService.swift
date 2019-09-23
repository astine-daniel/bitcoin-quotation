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
}

// MARK: - Private extension
private extension APIServiceProtocol {
    typealias ChartData = ResponseModel.ChartData

    @discardableResult
    func request(resource: BlockchainResource) -> AnyPublisher<ChartData, NetworkingError> {
        request(resource)
    }
}
