//
//  EndPointTests.swift
//  LinkTests
//
//  Created by Frank Cheng on 2020/7/5.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import XCTest
import Combine
import Mocker
@testable import Link

public final class MockedData {
    public static let githubApi: Data = NSDataAsset(name: "github", bundle: .main)!.data
}

class EndPointTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        
        let originalURL = URL(string: "https://api.github.com")!
        
        let mock = Mock(url: originalURL, dataType: .json, statusCode: 200, data: [
            .get : MockedData.githubApi // Data containing the JSON response
        ])
        mock.register()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEndPointFetch() throws {
        let expect = XCTestExpectation()
        let helper = ApiHelper()
        let c = helper.fetch().sink(receiveCompletion: { _ in
            expect.fulfill()
        }) { (d) in
            XCTAssert(d.contains { $0.path == "starred_gists_url" && $0.value == "https://api.github.com/gists/starred" })
            XCTAssert(d.contains { $0.path == "a.b.c" && $0.value == "123"})
            XCTAssert(d.contains { $0.path == "b.d" && $0.value == "321"})
        }
        withExtendedLifetime(c) {}
        wait(for: [expect], timeout: 10.0)
    }
}
