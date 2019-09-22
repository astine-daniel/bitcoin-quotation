@testable import Common

import XCTest

final class HTTPContentTypeTests: XCTestCase {
    func testFormURLEncodedContentType() {
        XCTAssertEqual(
            HTTPContentType.formURLEncoded.description,
            "application/x-www-form-urlencoded; charset=utf-8"
        )
    }

    func testJsonContentType() {
        XCTAssertEqual(
            HTTPContentType.json.description,
            "application/json"
        )
    }

    func testMultipartContentType() {
        XCTAssertEqual(
            HTTPContentType.multipart(boundary: "test").description,
            "multipart/form-data; boundary=test"
        )
    }

    func testTextContentType() {
        XCTAssertEqual(
            HTTPContentType.text.description,
            "text/plain"
        )
    }
}
