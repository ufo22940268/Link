//
//  EndPointTests.swift
//  LinkTests
//
//  Created by Frank Cheng on 2020/7/5.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import XCTest
import Combine
import SwiftyJSON
@testable import Link

class EndPointTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEndPointFetch() throws {
        let expect = XCTestExpectation()
        let helper = ApiHelper()
        let cancellable = helper.fetch().sink(receiveCompletion: { _ in
            print("complete")
            expect.fulfill()
        }) { (d) in
            XCTAssert(d.contains { $0.path == "starred_gists_url" })
        }
        
        
//        let cancellable = URLSession.shared.dataTaskPublisher(for: URL(string: "https://api.github.com")!)
//            .map { try! JSON(data: $0.data) }
//            .sink(receiveCompletion: { _ in
//                expect.fulfill()
//            }) { (d) in
//                print("--------------------")
//                print(d["keys_url"])
//        }
        wait(for: [expect], timeout: 10.0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
