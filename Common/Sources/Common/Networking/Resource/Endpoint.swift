import Foundation

public struct Endpoint {
    // MARK: - Properties
    public let path: String
    public let queryItems: [URLQueryItem]

    // MARK: - Properties
    public init(path: String, queryItems: [URLQueryItem] = []) {
        self.path = path
        self.queryItems = queryItems
    }
}
