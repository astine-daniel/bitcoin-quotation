import Foundation

public protocol ResourceParameters {
    func encode(on request: URLRequestConvertible) throws -> URLRequest
}
