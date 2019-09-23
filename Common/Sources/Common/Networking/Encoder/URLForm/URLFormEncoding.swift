import Foundation

public struct URLFormEncoding {
    // MARK: - Properties
    public let arrayEncoding: URLFormEncoding.Array
    public let boolEncoding: URLFormEncoding.Bool
    public let dateEncoding: URLFormEncoding.Date
    public let spaceEncoding: URLFormEncoding.Space

    // MARK: - Initialization
    public init(arrayEncoding: URLFormEncoding.Array = .brackets,
                boolEncoding: URLFormEncoding.Bool = .numeric,
                dateEncoding: URLFormEncoding.Date = .deferredToDate,
                spaceEncoding: URLFormEncoding.Space = .percentEscaped) {
        self.arrayEncoding = arrayEncoding
        self.boolEncoding = boolEncoding
        self.dateEncoding = dateEncoding
        self.spaceEncoding = spaceEncoding
    }
}

public extension URLFormEncoding {
    // MARK: - Bool
    enum Bool {
        case numeric
        case literal

        func encode(_ value: Swift.Bool) -> String {
            switch self {
            case .numeric: return "\(value.intValue)"
            case .literal: return value.stringValue
            }
        }
    }

    // MARK: - Date
    enum Date {
        case deferredToDate
        case secondsSince1970
        case millisecondsSince1970
        case iso8601
        case formatted(DateFormatter)
        case custom((Foundation.Date) throws -> String)

        func encode(_ value: Foundation.Date) throws -> String? {
            switch self {
            case .deferredToDate:
                return nil
            case .secondsSince1970:
                return String(value.timeIntervalSince1970)
            case .millisecondsSince1970:
                return String(value.timeIntervalSince1970 * 1_000)
            case .iso8601:
                return URLFormEncoding.Date.iso8601Formatter.string(from: value)
            case let .formatted(formatter):
                return formatter.string(from: value)
            case let .custom(closure):
                return try closure(value)
            }
        }
    }

    // MARK: - Array
    enum Array {
        case brackets
        case noBrackets

        func encode(_ key: String) -> String {
            switch self {
            case .brackets: return "\(key)[]"
            case .noBrackets: return key
            }
        }
    }

    // MARK: - SpaceEncoding
    enum Space {
        case percentEscaped
        case plusReplaced

        func encode(_ string: String) -> String {
            switch self {
            case .percentEscaped: return string.replacingOccurrences(of: " ", with: "%20")
            case .plusReplaced: return string.replacingOccurrences(of: " ", with: "+")
            }
        }
    }
}

// MARK: - URLEncoding.Date private extension
private extension URLFormEncoding.Date {
    static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime

        return formatter
    }()
}

// MARK: - Bool helper extension
private extension Swift.Bool {
    var intValue: Int {
        guard self else { return 0 }
        return 1
    }

    var stringValue: String {
        return String(self)
    }
}
