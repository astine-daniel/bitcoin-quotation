@testable import Common

import XCTest

final class HTTPMethodTests: XCTestCase {
    func testGetMethod() { test(method: .get, expected: "GET") }
    func testHeadMethod() { test(method: .head, expected: "HEAD") }
    func testPostMethod() { test(method: .post, expected: "POST") }
    func testPutMethod() { test(method: .put, expected: "PUT") }
    func testDeleteMethod() { test(method: .delete, expected: "DELETE") }
    func testConnectMethod() { test(method: .connect, expected: "CONNECT") }
    func testOptionsMethod() { test(method: .options, expected: "OPTIONS") }
    func testTraceMethod() { test(method: .trace, expected: "TRACE") }
}

private extension HTTPMethodTests {
    func test(method: HTTPMethod, expected expectedValue: String) {
        XCTAssertEqual(
            method.rawValue,
            expectedValue,
            "\(expectedValue.lowercased()) method should have value '\(expectedValue)'"
        )
    }
}
