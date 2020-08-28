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
        try! context.save()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParseURL() {
        print("parse url")
        var s = "http://biubiubiu.hopto.org/link/github.json"
        XCTAssert(s.hostname == "biubiubiu.hopto.org")
        s = "http://biubiubiu.hopto.org"
        XCTAssert(s.hostname == "biubiubiu.hopto.org")
    }

    func testCoreData() {
        print("testCoreData")
        print("child fetch", try? context.fetch(EndPointEntity.fetchRequest()))
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = context
        let entity = EndPointEntity(context: context)
        entity.url = "asdf11"
        print("child", childContext.insertedObjects)
        print("parent", context.insertedObjects)
        print("id1", entity.objectID)
        try! context.save()
        print("id2", entity.objectID)
        entity.url = "kk"
        try! context.save()
        print("id3", entity.objectID)
        
        let e2 = (try! childContext.fetch(EndPointEntity.fetchRequest())).first! as! EndPointEntity
        e2.url = "iii"
        print("id4", e2.objectID)

        print("child fetch", try? context.fetch(EndPointEntity.fetchRequest()))
        print("parent fetch", try? context.fetch(EndPointEntity.fetchRequest()))
                
    }
}
