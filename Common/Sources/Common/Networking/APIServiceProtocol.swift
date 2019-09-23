import Combine

public protocol APIServiceProtocol {
    @discardableResult
    func request<T>(_ resource: Resource) -> AnyPublisher<T, NetworkingError> where T: Decodable
}
