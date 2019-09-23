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
}
