//
//  URLTests.swift
//  LinkTests
//
//  Created by Frank Cheng on 2020/8/30.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import XCTest
@testable import Link

class URLTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testExtractPath() {
        let s = "http://biubiubiu.hopto.org/link/github.json"
        XCTAssertEqual(s.endPointPath, "/link/github.json")
        
        let s2 = "http://api.github.com/"
        XCTAssertEqual(s2.endPointPath, "/")
        
        let s3 = "http://api.github.com"
        XCTAssertEqual(s3.endPointPath, "/")
        
        XCTAssertNil("asdfasdf".endPointPath)
    }
}
