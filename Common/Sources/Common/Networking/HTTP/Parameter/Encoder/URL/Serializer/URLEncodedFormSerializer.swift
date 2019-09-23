import Foundation

public struct URLEncodedFormSerializer {
    // MARK: - Properties
    private let arrayEncoding: URLFormEncoding.Array
    private let spaceEncoding: URLFormEncoding.Space
    private let allowedCharacters: CharacterSet

    // MARK: - Initialization
    public init(arrayEncoding: URLFormEncoding.Array,
                spaceEncoding: URLFormEncoding.Space,
                allowedCharacters: CharacterSet) {
        self.arrayEncoding = arrayEncoding
        self.spaceEncoding = spaceEncoding
        self.allowedCharacters = allowedCharacters
    }
}

// MARK: - Methods
public extension URLEncodedFormSerializer {
    func serialize(_ object: [String: URLFormComponent]) -> String {
        let output = object.map { serialize($0.value, forKey: $0.key) }
        return output.joined(separator: "&")
    }
}

// MARK: - Private extension
private extension URLEncodedFormSerializer {
    func serialize(_ component: URLFormComponent, forKey key: String) -> String {
        switch component {
        case let .string(string):
            return "\(escape(key))=\(escape(string))"
        case let .array(array):
            return serialize(array, forKey: key)
        case let .object(object):
            return serialize(object, forKey: key)
        }
    }

    func serialize(_ array: [URLFormComponent], forKey key: String) -> String {
        let segments: [String] = array.map {
            let keyPath = self.arrayEncoding.encode(key)
            return serialize($0, forKey: keyPath)
        }

        return segments.joined(separator: "&")
    }

    func serialize(_ object: [String: URLFormComponent], forKey key: String) -> String {
        let segments: [String] = object.map {
            let keyPath = "[\($0.key)]"
            return serialize($0.value, forKey: key + keyPath)
        }

        return segments.joined(separator: "&")
    }

    func escape(_ query: String) -> String {
        var allowedCharactersWithSpace = allowedCharacters
        allowedCharactersWithSpace.insert(charactersIn: " ")

        let escapedQuery = query
            .addingPercentEncoding(withAllowedCharacters: allowedCharactersWithSpace)
            ?? query

        let spaceEncodedQuery = spaceEncoding.encode(escapedQuery)
        return spaceEncodedQuery
    }
}
