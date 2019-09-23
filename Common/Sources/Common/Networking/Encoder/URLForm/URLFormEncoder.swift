import Foundation

public struct URLFormEncoder {
    // MARK: - Properties
    private let context: URLFormEncoder.Context

    private let boolEncoding: URLFormEncoding.Bool
    private let dateEncoding: URLFormEncoding.Date

    public let codingPath: [CodingKey]

    // MARK: - Initialization
    public init(context: URLFormEncoder.Context,
                codingPath: [CodingKey] = [],
                boolEncoding: URLFormEncoding.Bool,
                dateEncoding: URLFormEncoding.Date) {
        self.context = context
        self.codingPath = codingPath
        self.boolEncoding = boolEncoding
        self.dateEncoding = dateEncoding
    }
}

// MARK: - Encoder extension
extension URLFormEncoder: Encoder {
    // Returns an empty dictionary, as this encoder doesn't support userInfo.
    public var userInfo: [CodingUserInfoKey: Any] { [:] }

    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        let container = URLFormEncoder.KeyedContainer<Key>(context: context,
                                                           codingPath: codingPath,
                                                           boolEncoding: boolEncoding,
                                                           dateEncoding: dateEncoding)
        return KeyedEncodingContainer(container)
    }

    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        URLFormEncoder.UnkeyedContainer(context: context,
                                        codingPath: codingPath,
                                        boolEncoding: boolEncoding,
                                        dateEncoding: dateEncoding)
    }

    public func singleValueContainer() -> SingleValueEncodingContainer {
        URLFormEncoder.SingleValueContainer(context: context,
                                            codingPath: codingPath,
                                            boolEncoding: boolEncoding,
                                            dateEncoding: dateEncoding)
    }
}

// MARK: - URLFormEncoder.Context
public extension URLFormEncoder {
    final class Context {
        // MARK: - Properties
        public var component: URLFormComponent

        // MARK: - Initialization
        public init(_ component: URLFormComponent) {
            self.component = component
        }
    }
}

// MARK: - URLFormEncoder.KeyedContainer
private extension URLFormEncoder {
    struct KeyedContainer<Key> where Key: CodingKey {
        // MARK: - Properties
        private let context: URLFormEncoder.Context
        private let boolEncoding: URLFormEncoding.Bool
        private let dateEncoding: URLFormEncoding.Date

        let codingPath: [CodingKey]

        // MARK: - Initialization
        init(context: URLFormEncoder.Context,
             codingPath: [CodingKey],
             boolEncoding: URLFormEncoding.Bool,
             dateEncoding: URLFormEncoding.Date) {
            self.context = context
            self.codingPath = codingPath
            self.boolEncoding = boolEncoding
            self.dateEncoding = dateEncoding
        }
    }
}

// MARK: - URLFormEncoder.KeyedContainer KeyedEncodingContainerProtocol extension
extension URLFormEncoder.KeyedContainer: KeyedEncodingContainerProtocol {
    func encodeNil(forKey key: Key) throws {
        let context = EncodingError.Context(codingPath: codingPath,
                                            debugDescription: "URLFormEncoder cannot encode nil values.")
        throw EncodingError.invalidValue("\(key): nil", context)
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        var container = nestedSingleValueEncoder(for: key)
        try container.encode(value)
    }

    func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let container = URLFormEncoder.KeyedContainer<NestedKey>(context: context,
                                                                 codingPath: nestedCodingPath(for: key),
                                                                 boolEncoding: boolEncoding,
                                                                 dateEncoding: dateEncoding)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = URLFormEncoder.UnkeyedContainer(context: context,
                                                        codingPath: nestedCodingPath(for: key),
                                                        boolEncoding: boolEncoding,
                                                        dateEncoding: dateEncoding)
        return container
    }

    func superEncoder() -> Encoder {
        return URLFormEncoder(context: context,
                              codingPath: codingPath,
                              boolEncoding: boolEncoding,
                              dateEncoding: dateEncoding)
    }

    func superEncoder(forKey key: Key) -> Encoder {
        return URLFormEncoder(context: context,
                              codingPath: nestedCodingPath(for: key),
                              boolEncoding: boolEncoding,
                              dateEncoding: dateEncoding)
    }
}

// MARK: - URLFormEncoder.KeyedContainer private extension
private extension URLFormEncoder.KeyedContainer {
    func nestedCodingPath(for key: CodingKey) -> [CodingKey] { codingPath + [key] }

    func nestedSingleValueEncoder(for key: Key) -> SingleValueEncodingContainer {
        let container = URLFormEncoder.SingleValueContainer(context: context,
                                                            codingPath: codingPath,
                                                            boolEncoding: boolEncoding,
                                                            dateEncoding: dateEncoding)
        return container
    }
}

// MARK: - URLFormEncoder.SingleValueContainer
private extension URLFormEncoder {
    final class SingleValueContainer {
        // MARK: - Properties
        let codingPath: [CodingKey]

        private var canEncodeNewValue = true

        private let context: URLFormEncoder.Context
        private let boolEncoding: URLFormEncoding.Bool
        private let dateEncoding: URLFormEncoding.Date

        // MARK: - Initialization
        init(context: URLFormEncoder.Context,
             codingPath: [CodingKey],
             boolEncoding: URLFormEncoding.Bool,
             dateEncoding: URLFormEncoding.Date) {
            self.context = context
            self.codingPath = codingPath
            self.boolEncoding = boolEncoding
            self.dateEncoding = dateEncoding
        }
    }
}

// MARK: - URLFormEncoder.SingleValueContainer SingleValueEncodingContainer extension
extension URLFormEncoder.SingleValueContainer: SingleValueEncodingContainer {
    func encodeNil() throws {
        try checkCanEncode(value: nil)
        defer { canEncodeNewValue = false }

        let context = EncodingError.Context(codingPath: codingPath,
                                            debugDescription: "URLFormEncoder cannot encode nil values.")
        throw EncodingError.invalidValue("nil", context)
    }

    func encode(_ value: Bool) throws {
        try encode(value, as: String(boolEncoding.encode(value)))
    }

    func encode(_ value: String) throws {
        try encode(value, as: value)
    }

    func encode(_ value: Double) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: Float) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: Int) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: Int8) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: Int16) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: Int32) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: Int64) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: UInt) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: UInt8) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: UInt16) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: UInt32) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: UInt64) throws {
        try encode(value, as: String(value))
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        switch value {
        case let date as Date:
            guard let string = try dateEncoding.encode(date) else {
                // swiftlint:disable:next fallthrough
                fallthrough
            }

            try encode(value, as: string)

        default:
            try checkCanEncode(value: value)
            defer { canEncodeNewValue = false }

            let encoder = URLFormEncoder(context: context,
                                         codingPath: codingPath,
                                         boolEncoding: boolEncoding,
                                         dateEncoding: dateEncoding)
            try value.encode(to: encoder)
        }
    }
}

// MARK: - URLFormEncoder.SingleValueContainer private extension
private extension URLFormEncoder.SingleValueContainer {
    func checkCanEncode(value: Any?) throws {
        guard canEncodeNewValue == false else { return }

        let debugDescription = "Attempt to encode value through single value container when previously value already encoded."
        let context = EncodingError.Context(codingPath: codingPath,
                                            debugDescription: debugDescription)
        throw EncodingError.invalidValue(value as Any, context)
    }

    func encode<T>(_ value: T, as string: String) throws where T: Encodable {
        try checkCanEncode(value: value)
        defer { canEncodeNewValue = false }

        context.component.set(to: .string(string), at: codingPath)
    }
}

// MARK: - URLFormEncoder.UnkeyedContainer
private extension URLFormEncoder {
    final class UnkeyedContainer {
        // MARK: - Properties
        let codingPath: [CodingKey]

        var count = 0
        var nestedCodingPath: [CodingKey] {
            return codingPath + [AnyCodingKey(intValue: count)!]
        }

        private let context: URLFormEncoder.Context
        private let boolEncoding: URLFormEncoding.Bool
        private let dateEncoding: URLFormEncoding.Date

        // MARK: - Initialization
        init(context: URLFormEncoder.Context,
             codingPath: [CodingKey],
             boolEncoding: URLFormEncoding.Bool,
             dateEncoding: URLFormEncoding.Date) {
            self.context = context
            self.codingPath = codingPath
            self.boolEncoding = boolEncoding
            self.dateEncoding = dateEncoding
        }
    }
}

// MARK: - URLFormEncoder.UnkeyedContainer UnkeyedEncodingContainer extension
extension URLFormEncoder.UnkeyedContainer: UnkeyedEncodingContainer {
    func encodeNil() throws {
        let context = EncodingError.Context(codingPath: codingPath,
                                            debugDescription: "URLFormEncoder cannot encode nil values.")
        throw EncodingError.invalidValue("nil", context)
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        var container = nestedSingleValueEncoder()
        try container.encode(value)
    }

    func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        defer { count += 1 }

        let container = URLFormEncoder.KeyedContainer<NestedKey>(context: context,
                                                                 codingPath: nestedCodingPath,
                                                                 boolEncoding: boolEncoding,
                                                                 dateEncoding: dateEncoding)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        defer { count += 1 }

        return URLFormEncoder.UnkeyedContainer(context: context,
                                               codingPath: nestedCodingPath,
                                               boolEncoding: boolEncoding,
                                               dateEncoding: dateEncoding)
    }

    func superEncoder() -> Encoder {
        defer { count += 1 }

        return URLFormEncoder(context: context,
                              codingPath: codingPath,
                              boolEncoding: boolEncoding,
                              dateEncoding: dateEncoding)
    }
}

// MARK: - URLFormEncoder.UnkeyedContainer private extension
private extension URLFormEncoder.UnkeyedContainer {
    func nestedSingleValueEncoder() -> SingleValueEncodingContainer {
        defer { count += 1 }

        return URLFormEncoder.SingleValueContainer(context: context,
                                                   codingPath: nestedCodingPath,
                                                   boolEncoding: boolEncoding,
                                                   dateEncoding: dateEncoding)
    }
}

// MARK: - URLFormEncoder.AnyCodingKey
private extension URLFormEncoder {
    struct AnyCodingKey: CodingKey, Hashable {
        // MARK: - Properties
        let stringValue: String
        let intValue: Int?

        // MARK: - Initialization
        init?(stringValue: String) {
            self.stringValue = stringValue
            intValue = nil
        }

        init?(intValue: Int) {
            stringValue = "\(intValue)"
            self.intValue = intValue
        }

        init<Key>(_ base: Key) where Key: CodingKey {
            if let intValue = base.intValue {
                self.init(intValue: intValue)!
            } else {
                self.init(stringValue: base.stringValue)!
            }
        }
    }
}
