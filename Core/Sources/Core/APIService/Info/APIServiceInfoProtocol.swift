import Common

public protocol APIServiceInfoProtocol {
    var baseURL: URLConvertible { get }
    var resultFormat: String { get }
}
