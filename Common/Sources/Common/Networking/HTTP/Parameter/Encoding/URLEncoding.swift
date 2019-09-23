import Foundation

public struct URLEncoding {
    // MARK: - Properties
    private let destination: Destination
    private let arrayEncoding: ArrayEncoding
    private let boolEncoding: BoolEncoding

    // MARK: - Initialization
    public init(destination: Destination = .methodDependent,
                arrayEncoding: ArrayEncoding = .brackets,
                boolEncoding: BoolEncoding = .numeric) {
        self.destination = destination
        self.arrayEncoding = arrayEncoding
        self.boolEncoding = boolEncoding
    }
}

// MARK: - Default URL encodings
public extension URLEncoding {
    static var `default`: URLEncoding { URLEncoding() }
    static var queryString: URLEncoding { URLEncoding(destination: .queryString) }
    static var httpBody: URLEncoding { URLEncoding(destination: .httpBody) }
}

// MARK: - ParameterEncoding extension
extension URLEncoding: ParameterEncoding {
    public func encode(_ parameters: Parameters?, into request: URLRequest) throws -> URLRequest {
        guard let parameters = parameters else { return request }

        guard let method = request.method, destination.encodesParametersInURL(for: method) else {
            return try encodeUsingHTTPBody(parameters, into: request)
        }

        return try encodeUsingQuery(parameters, into: request)
    }
}

// MARK: - Nested types
public extension URLEncoding {
    enum Destination {
        case methodDependent
        case queryString
        case httpBody

        func encodesParametersInURL(for method: HTTPMethod) -> Bool {
            switch self {
            case .methodDependent:
                return [.get, .head, .delete].contains(method)
            case .queryString:
                return true
            case .httpBody:
                return false
            }
        }
    }
}

public extension URLEncoding {
    enum ArrayEncoding {
        case brackets
        case noBrackets

        func encode(_ key: String) -> String {
            switch self {
            case .brackets: return "\(key)[]"
            case .noBrackets: return key
            }
        }
    }

    enum BoolEncoding {
        case numeric
        case literal

        func encode(_ value: Bool) -> String {
            switch self {
            case .numeric: return "\(value.intValue)"
            case .literal: return value.stringValue
            }
        }
    }
}

// MARK: - Private extension
private extension URLEncoding {
    func encodeUsingQuery(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        guard let url = request.url else {
            throw NetworkingError.parameterEncodingFailed(reason: .missingURL)
        }

        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            parameters.isEmpty == false else {
                return request
        }

        var request = request
        let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
        urlComponents.percentEncodedQuery = percentEncodedQuery
        request.url = urlComponents.url

        return request
    }

    func encodeUsingHTTPBody(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        var request = request

        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.headers.add(.contentType(.formURLEncoded))
        }

        request.httpBody = Data(query(parameters).utf8)

        return request
    }

    func query(_ parameters: Parameters) -> String {
        let components: [(String, String)] = parameters.sorted { $0.key < $1.key }
            .flatMap { self.queryComponents(fromKey: $0.key, value: $0.value) }

        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }

    func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []

        switch value {
        case let dictionary as [String: Any]:
            components += dictionary.flatMap { self.queryComponents(fromKey: "\(key)[\($0)]", value: $1) }
        case let array as [Any]:
            components += array.flatMap { self.queryComponents(fromKey: arrayEncoding.encode(key), value: $0) }
        case let value as NSNumber:
            if value.isBool {
                components.append((escape(key), escape(boolEncoding.encode(value.boolValue))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        case let bool as Bool:
            components.append((escape(key), escape(boolEncoding.encode(bool))))
        default:
            components.append((escape(key), escape("\(value)")))
        }

        return components
    }

    func escape(_ string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowedByRFC3986)
            ?? string
    }
}

// MARK: - Bool helper extension
private extension Bool {
    var intValue: Int {
        guard self else { return 0 }
        return 1
    }

    var stringValue: String { String(self) }
}

// MARK: - NSNumber helper extension
private extension NSNumber {
    var isBool: Bool { CFBooleanGetTypeID() == CFGetTypeID(self) }
}
