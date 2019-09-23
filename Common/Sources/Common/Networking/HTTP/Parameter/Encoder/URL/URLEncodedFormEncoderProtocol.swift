import Foundation

public protocol URLEncodedFormEncoderProtocol {
    func encode(_ value: Encodable) throws -> Data
    func encode(_ value: Encodable) throws -> String
}
