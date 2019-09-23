import Foundation

public struct DictionaryResourceParameters {
    // MARK: - Properties
    private let values: [String: Any]
    private let encoding: ParameterEncoding

    // MARK: - Initialization
    public init(values: [String: Any], encoding: ParameterEncoding = JSONEncoding.default) {
        self.values = values
        self.encoding = encoding
    }
}

// MARK: - ResourceParameters extension
extension DictionaryResourceParameters: ResourceParameters {
    public func encode(on request: URLRequestConvertible) throws -> URLRequest {
        let request = try request.asURLRequest()
        return try encoding.encode(values, into: request)
    }
}
