import Foundation

public protocol ResourceParser {
    func parse<T: Decodable>(_ data: Data?) throws -> T
}
