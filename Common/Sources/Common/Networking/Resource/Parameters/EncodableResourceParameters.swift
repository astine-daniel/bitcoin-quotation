import Foundation

public struct EncodableResourceParameters<T> where T: Encodable {
    // MARK: - Properties
    private let value: T
    private let encoder: ParameterEncoder

    // MARK: - Initialization
    public init(value: T, encoder: ParameterEncoder = JSONParameterEncoder()) {
        self.value = value
        self.encoder = encoder
    }
}

// MARK: - ResourceParameters extension
extension EncodableResourceParameters: ResourceParameters {
    public func encode(on request: URLRequestConvertible) throws -> URLRequest {
        let request = try request.asURLRequest()
        return try encoder.encode(value, into: request)
    }
}
