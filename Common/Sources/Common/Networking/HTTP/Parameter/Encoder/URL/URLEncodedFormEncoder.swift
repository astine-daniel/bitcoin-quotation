import Foundation

struct URLEncodedFormEncoder {
    // MARK: - Properties
    private let encoding: URLFormEncoding
    private let allowedCharacters: CharacterSet

    // MARK: - Initialization
    init(encoding: URLFormEncoding = URLFormEncoding(),
         allowedCharacters: CharacterSet = .urlQueryAllowedByRFC3986) {
        self.encoding = encoding
        self.allowedCharacters = allowedCharacters
    }
}

// MARK: - URLEncodedFormEncoderProtocol extension
extension URLEncodedFormEncoder: URLEncodedFormEncoderProtocol {
    func encode(_ value: Encodable) throws -> Data {
        let string: String = try encode(value)
        return Data(string.utf8)
    }

    func encode(_ value: Encodable) throws -> String {
        let component: URLFormComponent = try encode(value)

        guard case let .object(object) = component else {
            throw Error.invalidRootObject("\(component)")
        }

        let serializer = URLEncodedFormSerializer(arrayEncoding: encoding.arrayEncoding,
                                                  spaceEncoding: encoding.spaceEncoding,
                                                  allowedCharacters: allowedCharacters)
        let query = serializer.serialize(object)
        return query
    }
}

// MARK: - URLEncodedFormEncoder private extension
private extension URLEncodedFormEncoder {
    func encode(_ value: Encodable) throws -> URLFormComponent {
        let context = URLFormEncoder.Context(.object([:]))
        let encoder = URLFormEncoder(context: context,
                                     boolEncoding: encoding.boolEncoding,
                                     dateEncoding: encoding.dateEncoding)

        try value.encode(to: encoder)

        return context.component
    }
}

// MARK: - URLEncodedFormEncoder error extension
extension URLEncodedFormEncoder {
    enum Error: Swift.Error {
        case invalidRootObject(String)

        var localizedDescription: String {
            switch self {
            case let .invalidRootObject(object):
                return "URLEncodedFormEncoder requires keyed root object. Received \(object) instead."
            }
        }
    }
}
