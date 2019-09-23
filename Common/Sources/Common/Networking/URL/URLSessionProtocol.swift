import Foundation

public protocol URLSessionProtocol {
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
}

// MARK: - URLSession extension
extension URLSession: URLSessionProtocol { }
