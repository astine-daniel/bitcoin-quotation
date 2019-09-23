import Foundation

public struct URLEncodedFormParameterEncoder {
    // MARK: - Properties
    private let encoder: URLEncodedFormEncoderProtocol
    private let destination: Destination

    // MARK: - Initialization
    public init(destination: Destination = .methodDependent) {
        self.init(encoder: URLEncodedFormEncoder(), destination: destination)
    }

    public init(encoder: URLEncodedFormEncoderProtocol, destination: Destination) {
        self.encoder = encoder
        self.destination = destination
    }
}

// MARK: - ParameterEncoder extension
extension URLEncodedFormParameterEncoder: ParameterEncoder {
    public func encode<Parameters>(
        _ parameters: Parameters?,
        into request: URLRequest) throws -> URLRequest where Parameters: Encodable {
        guard let parameters = parameters else { return request }

        guard let url = request.url else {
            throw NetworkingError.parameterEncoderFailed(reason: .missingRequiredComponent(.url))
        }

        guard let rawMethod = request.httpMethod, let method = HTTPMethod(rawValue: rawMethod) else {
            let rawValue = request.httpMethod ?? "nil"
            throw NetworkingError.parameterEncoderFailed(reason:
                .missingRequiredComponent(.httpMethod(rawValue: rawValue)))
        }

        guard destination.encodesParametersInURL(for: method),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                return try encodeUsingHTTPBody(parameters, into: request)
        }

        return try encodeUsingQueryString(parameters, into: request, with: components)
    }
}

// MARK: - Destination nested type
public extension URLEncodedFormParameterEncoder {
    enum Destination {
        case methodDependent
        case queryString
        case httpBody

        func encodesParametersInURL(for method: HTTPMethod) -> Bool {
            switch self {
            case .methodDependent:
                let methods: [HTTPMethod] = [.get, .head, .delete]
                return methods.contains(method)
            case .queryString:
                return true
            case .httpBody:
                return false
            }
        }
    }
}

// MARK: - Private extension
private extension URLEncodedFormParameterEncoder {
    func encodeUsingQueryString<Parameters>(
        _ parameters: Parameters,
        into request: URLRequest,
        with components: URLComponents) throws -> URLRequest where Parameters: Encodable {
        var request = request
        var components = components

        let query: String = try Result { try encoder.encode(parameters) }
            .mapError { NetworkingError.parameterEncoderFailed(reason: .encoderFailed(error: $0)) }.get()

        let newQueryString = [components.percentEncodedQuery, query].compactMap { $0 }.joined(separator: "&")
        components.percentEncodedQuery = newQueryString.isEmpty ? nil : newQueryString

        guard let newURL = components.url else {
            throw NetworkingError.parameterEncoderFailed(reason: .missingRequiredComponent(.url))
        }

        request.url = newURL

        return request
    }

    func encodeUsingHTTPBody<Parameters>(
        _ parameters: Parameters,
        into request: URLRequest) throws -> URLRequest where Parameters: Encodable {
        var request = request

        if request.headers["Content-Type"] == nil {
            request.headers.add(.contentType(.formURLEncoded))
        }

        request.httpBody = try Result { try encoder.encode(parameters) }
            .mapError { NetworkingError.parameterEncoderFailed(reason: .encoderFailed(error: $0)) }.get()

        return request
    }
}
