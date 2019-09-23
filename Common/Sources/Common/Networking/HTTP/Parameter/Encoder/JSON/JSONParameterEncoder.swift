import Foundation

public struct JSONParameterEncoder {
    // MARK: - Properties
    private let jsonEncoder: JSONEncoderProtocol

    // MARK: - Initialization
    public init(jsonEncoder: JSONEncoderProtocol = JSONEncoder()) {
        self.jsonEncoder = jsonEncoder
    }
}

// MARK: - ParameterEncoder extension
extension JSONParameterEncoder: ParameterEncoder {
    public func encode<Parameters>(
        _ parameters: Parameters?,
        into request: URLRequest) throws -> URLRequest where Parameters: Encodable {
        guard let parameters = parameters else { return request }
        var request = request

        do {
            let data = try jsonEncoder.encode(parameters)
            request.httpBody = data

            if request.headers["Content-Type"] == nil {
                request.headers.add(.contentType(.json))
            }
        } catch {
            throw NetworkingError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }

        return request
    }
}
