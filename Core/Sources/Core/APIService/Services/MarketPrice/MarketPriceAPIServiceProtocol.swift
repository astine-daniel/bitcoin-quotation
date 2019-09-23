import Combine
import Common

public protocol MarketPriceAPIServiceProtocol {
    func marketPrice(ofLast days: Int) -> AnyPublisher<ResponseModel.MarketPrice, NetworkingError>
}

public extension MarketPriceAPIServiceProtocol {
    func marketPrice() -> AnyPublisher<ResponseModel.MarketPrice, NetworkingError> {
        return marketPrice(ofLast: 30)
    }
}
