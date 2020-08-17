//
//  EndPointTests.swift
//  LinkTests
//
//  Created by Frank Cheng on 2020/7/5.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import CoreData
@testable import Link
import XCTest

class EndPointTests: XCTestCase {
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJSON() {
        let data: Data = """
        [{"a": 1, "b": 2}]
        """.data(using: .utf8)!

        var j = try! JSON(data: data)
        j["c"] = 3
        j.rawDictionary.removeValue(forKey: "a")
        print(type(of: j.rawValue))
        let s = j.rawString(options: [JSONSerialization.WritingOptions.sortedKeys])
        print("-------------", s)
    }

    func testAaa() {
        let context = getPersistentContainer().viewContext
        let domain = DomainEntity(context: context)
        domain.name = "dfef"
        domain.endPoints = []
        let d = EndPointEntity(context: context)
        d.url = "http://biubiubiu.hopto.org:9000/link/github.json"
        d.domain = domain
        try? context.save()
    }
}
