import Foundation

public protocol JSONEncoderProtocol {
    func encode<T>(_ value: T) throws -> Data where T: Encodable
}

// MARK: - JSONEncoder extension support
extension JSONEncoder: JSONEncoderProtocol { }
