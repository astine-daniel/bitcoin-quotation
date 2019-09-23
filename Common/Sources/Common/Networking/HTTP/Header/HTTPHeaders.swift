import Foundation

public struct HTTPHeaders {
    // MARK: - Properties
    private var headers: [HTTPHeader]

    // MARK: - Initialization
    public init() {
        self.headers = []
    }

    public init(_ headers: [HTTPHeader]) {
        self.init()

        headers.forEach { update($0) }
    }

    public init(_ dictionary: [String: String]) {
        self.init()

        dictionary.forEach { update(name: $0.key, value: $0.value) }
    }
}

// MARK: - Methods extension
public extension HTTPHeaders {
    // MARK: - Add
    mutating func add(_ header: HTTPHeader) {
        update(header)
    }

    mutating func add(name: String, value: String) {
        add(HTTPHeader(name: name, value: value))
    }

    // MARK: - Remove
    mutating func remove(name: String) {
        guard let index = headers.index(of: name) else { return }
        headers.remove(at: index)
    }

    mutating func remove(_ header: HTTPHeader) {
        remove(name: header.name)
    }

    // MARK: - Update
    mutating func update(_ header: HTTPHeader) {
        guard let index = headers.index(of: header.name) else {
            headers.append(header)
            return
        }

        headers.replaceSubrange(index...index, with: [header])
    }

    mutating func update(name: String, value: String) {
        update(HTTPHeader(name: name, value: value))
    }

    // MARK: - Get value
    func value(for name: String) -> String? {
        guard let index = headers.index(of: name) else { return nil }
        return headers[index].value
    }

    // MARK: - Dictionary conversion
    func asDictionary() -> [String: String] {
        headers.reduce(into: [:]) { $0[$1.name] = $1.value }
    }

    // MARK: - Subscript
    subscript(_ name: String) -> String? {
        get { return value(for: name) }
        set {
            guard let value = newValue else {
                remove(name: name)
                return
            }

            update(name: name, value: value)
        }
    }
}

// MARK: - ExpressibleByDictionaryLiteral extension
extension HTTPHeaders: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        self.init()

        elements.forEach { update(name: $0.0, value: $0.1) }
    }
}

// MARK: - URLRequest support extension
public extension URLRequest {
    var headers: HTTPHeaders {
        get { return allHTTPHeaderFields.map(HTTPHeaders.init) ?? HTTPHeaders() }
        set { allHTTPHeaderFields = newValue.asDictionary() }
    }
}
