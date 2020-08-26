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
    var context = getPersistentContainer().viewContext

    override func setUpWithError() throws {
        let entities = [ApiEntity.self, EndPointEntity.self, DomainEntity.self]
        for entity in entities {
            for e in try! context.fetch(entity.fetchRequest()) {
                context.delete(e as! NSManagedObject)
            }
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testParseURL() {
        var s = "http://biubiubiu.hopto.org/link/github.json"
        XCTAssert(s.hostname == "biubiubiu.hopto.org")
        s = "http://biubiubiu.hopto.org"
        XCTAssert(s.hostname == "biubiubiu.hopto.org")
    }
}
