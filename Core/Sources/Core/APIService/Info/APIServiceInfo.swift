import Common
import Foundation

struct APIServiceInfo { }

extension APIServiceInfo {
    static var `default`: APIServiceInfo { APIServiceInfo() }
}

extension APIServiceInfo: APIServiceInfoProtocol {
    var baseURL: URLConvertible { "https://api.blockchain.info" }
    var resultFormat: String { "json" }
}

extension URLQueryItem {
    static func resultFormat(value: String) -> URLQueryItem {
        return URLQueryItem(name: "format", value: value)
    }
}
