import Common

public protocol APIServiceInfoProtocol {
    var baseURL: URLConvertible { get }
    var format: String { get }
}
