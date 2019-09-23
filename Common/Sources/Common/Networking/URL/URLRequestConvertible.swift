import Foundation

public protocol URLRequestConvertible {
    func asURLRequest() throws -> URLRequest
}

// MARK: URLRequest extension
extension URLRequest: URLRequestConvertible {
    public func asURLRequest() throws -> URLRequest { self }
}
