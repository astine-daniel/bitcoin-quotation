import Combine
import Common

public struct MarketPriceAPIService {
    // MARK: - Properties
    private let apiService: APIServiceProtocol

    // MARK: - Initialization
    public init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
}

// MARK: - MarketPriceAPIServiceProtocol extension
extension MarketPriceAPIService: MarketPriceAPIServiceProtocol {
    public func marketPrice(ofLast days: Int) -> AnyPublisher<ResponseModel.MarketPrice, NetworkingError> {
        apiService.request(resource: .marketPrice(ofLast: days))
    }
}

// MARK: - Private extension
private extension APIServiceProtocol {
    typealias MarketPrice = ResponseModel.MarketPrice

    @discardableResult
    func request(resource: MarketPriceResource) -> AnyPublisher<MarketPrice, NetworkingError> {
        request(resource)
    }
}
