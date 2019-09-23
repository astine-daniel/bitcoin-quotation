public enum NetworkingError: Error {
    case invalidURL(url: URLConvertible)
    case parameterEncodingFailed(reason: ParameterEncodingFailureReason)
    case parameterEncoderFailed(reason: ParameterEncoderFailureReason)
    case unexpected(error: Error)
    case parseFailed(type: Any.Type)
    case statusCode(code: Int)
    case unknown
}

public extension NetworkingError {
    static func error(from statusCode: Int, validCodes: [Int] = []) -> NetworkingError? {
        let validCodes = Array(200 ..< 300) + validCodes
        guard validCodes.contains(statusCode) else {
            return .statusCode(code: statusCode)
        }

        return nil
    }
}

public extension NetworkingError {
    // MARK: - ParameterEnconding reasons
    enum ParameterEncodingFailureReason {
        case missingURL
        case jsonEncodingFailed(error: Error)
    }
}

public extension NetworkingError {
    enum ParameterEncoderFailureReason {
        case missingRequiredComponent(RequiredComponent)
        case encoderFailed(error: Error)
    }
}

public extension NetworkingError.ParameterEncoderFailureReason {
    enum RequiredComponent {
        case url
        case httpMethod(rawValue: String)
    }
}
