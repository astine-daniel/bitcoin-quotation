public enum HTTPContentType {
    case formURLEncoded
    case json
    case multipart(boundary: String)
    case text
}

// MARK: - CustomStringConvertible extension
extension HTTPContentType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .formURLEncoded:
            return "application/x-www-form-urlencoded; charset=utf-8"
        case .json:
            return "application/json"
        case let .multipart(boundary):
            return "multipart/form-data; boundary=\(boundary)"
        case .text:
            return "text/plain"
        }
    }
}
