import Foundation

public struct HTTPHeader: Hashable {
    // MARK: - Properties
    public let name: String
    public let value: String

    // MARK: - Initialization
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

// MARK: - Default headers
public extension HTTPHeader {
    static func accept(_ value: String) -> HTTPHeader {
        HTTPHeader(name: .accept, value: value)
    }

    static func acceptCharset(_ value: String) -> HTTPHeader {
        HTTPHeader(name: .acceptCharset, value: value)
    }

    static func acceptEncoding(_ value: String) -> HTTPHeader {
        HTTPHeader(name: .acceptEncoding, value: value)
    }

    static func acceptLanguage(_ value: String) -> HTTPHeader {
        HTTPHeader(name: .acceptLanguage, value: value)
    }

    static func authorization(_ value: String) -> HTTPHeader {
        HTTPHeader(name: .authorization, value: value)
    }

    static func authorization(username: String, password: String) -> HTTPHeader {
        let credential = Data("\(username):\(password)".utf8).base64EncodedString()
        return authorization("Basic \(credential)")
    }

    static func authorization(bearerToken: String) -> HTTPHeader {
        authorization("Bearer \(bearerToken)")
    }

    static func contentType(_ value: String) -> HTTPHeader {
        HTTPHeader(name: .contentType, value: value)
    }

    static func contentType(_ value: HTTPContentType) -> HTTPHeader {
        contentType(value.description)
    }

    static func userAgent(_ value: String) -> HTTPHeader {
        HTTPHeader(name: .userAgent, value: value)
    }
}

// MARK: - Common headers
public extension HTTPHeader {
    static let defaultAcceptEncoding: HTTPHeader = {
        let encodings: [String]
        if #available(iOS 11.0, macOS 10.13, tvOS 11.0, watchOS 4.0, *) {
            encodings = ["br", "gzip", "deflate"]
        } else {
            encodings = ["gzip", "deflate"]
        }

        return .acceptEncoding(qualityEncoded(encodings))
    }()

    static let defaultUserAgent: HTTPHeader = {
        guard let info = Bundle.main.infoDictionary else { return .userAgent("Networking") }

        let kCFBundleShortVersionKey = "CFBundleShortVersionString"

        let executable = info[kCFBundleExecutableKey as String] ?? "Unknown"
        let bundle = info[kCFBundleIdentifierKey as String] ?? "Unknown"
        let appVersion = info[kCFBundleShortVersionKey] ?? "Unknown"
        let appBuild = info[kCFBundleVersionKey as String] ?? "Unknown"

        let value = "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion))"

        return .userAgent(value)
    }()
}

// MARK: - Array extension
public extension Array where Element == HTTPHeader {
    func index(of name: String) -> Int? {
        let lowercasedName = name.lowercased()
        return firstIndex { $0.name.lowercased() == lowercasedName }
    }
}

// MARK: - Private extension
private extension HTTPHeader {
    enum Name: String {
        case accept = "Accept"
        case acceptCharset = "Accept-Charset"
        case acceptEncoding = "Accept-Encoding"
        case acceptLanguage = "Accept-Language"
        case authorization = "Authorization"
        case contentType = "Content-Type"
        case userAgent = "User-Agent"
    }

    init(name: HTTPHeader.Name, value: String) {
        self.name = name.rawValue
        self.value = value
    }

    static func qualityEncoded(_ encondings: [String]) -> String {
        encondings
            .enumerated()
            .map { encondingWithQuality($1, position: $0) }
            .joined(separator: ", ")
    }

    static func encondingWithQuality(_ encoding: String, position: Int) -> String {
        let priority = (Double(position) * 0.1)
        let quality: Double = (1.0 - priority)
        return "\(encoding);q=\(quality)"
    }

    static var osNameVersion: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

        return "\(osName) \(versionString)"
    }

    static var osName: String {
        #if os(iOS)
        return "iOS"
        #elseif os(watchOS)
        return "watchOS"
        #elseif os(tvOS)
        return "tvOS"
        #elseif os(macOS)
        return "macOS"
        #elseif os(Linux)
        return "Linux"
        #else
        return "Unknown"
        #endif
    }
}
