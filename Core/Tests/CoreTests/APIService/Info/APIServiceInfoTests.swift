@testable import Core

import XCTest

final class APIServiceInfoTests: XCTestCase {
    private var target: APIServiceInfoProtocol!

    override func setUp() {
        super.setUp()

        target = APIServiceInfo.default
    }

    func testBaseURLShouldBeValidURL() {
        var baseURL: URL?

        XCTAssertNoThrow(baseURL = try target.baseURL.asURL())
        XCTAssertNotNil(baseURL)
    }

    func testBaseURL() throws {
        let baseURL = try XCTUnwrap(target.baseURL.asURL())
        XCTAssertEqual(baseURL.absoluteString, "https://api.blockchain.info")
    }

    func testResultFormatShouldBeJSONFormat() {
        XCTAssertEqual(target.resultFormat, "json")
    }
}
