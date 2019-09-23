import Common
import Foundation

public struct APIServiceInfo { }

public extension APIServiceInfo {
    static var `default`: APIServiceInfo { APIServiceInfo() }
}

extension APIServiceInfo: APIServiceInfoProtocol {
    public var baseURL: URLConvertible { " https://api.blockchain.info" }
    public var format: String { "json" }
}

public extension URLQueryItem {
    static func format(value: String) -> URLQueryItem {
        return URLQueryItem(name: "format", value: value)
    }
}
