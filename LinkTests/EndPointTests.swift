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
    var cancellables = [AnyCancellable]()

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

    func testCoreData() {
//        print("testCoreData")
//        print("child fetch", try? context.fetch(EndPointEntity.fetchRequest()))
//        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        childContext.parent = context
//        let entity = EndPointEntity(context: context)
//        entity.url = "asdf11"
//        print("child", childContext.insertedObjects)
//        print("parent", context.insertedObjects)
//        print("id1", entity.objectID)
//        try! context.save()
//        print("id2", entity.objectID)
//        entity.url = "kk"
//        try! context.save()
//        print("id3", entity.objectID)
//
//        let e2 = (try! childContext.fetch(EndPointEntity.fetchRequest())).first! as! EndPointEntity
//        e2.url = "iii"
//        print("id4", e2.objectID)
//
//        print("child fetch", try? context.fetch(EndPointEntity.fetchRequest()))
//        print("parent fetch", try? context.fetch(EndPointEntity.fetchRequest()))
//        print("fetch many", try? context.fetchMany(EndPointEntity.self, "url == %@", "kk"))
//        print("fetch one", try? context.fetchOne(EndPointEntity.self, "url == %@", "kk"))
    }

    func testApiRequest() {
        let exp = XCTestExpectation()
        let info = LoginInfo(username: "aaa", appleUserId: "000929.22711429e1bb474d9faf0111a9a3c9df.2350")
        LoginManager.save(loginInfo: info)
        let agent = BackendAgent()
        let ee = EndPointEntity(context: context)
        ee.url = "a"

        let ae = ApiEntity(context: context)
        ae.paths = "apah"
        ae.watchValue = "b"
        ee.addToApi(ae)

        try! agent.upsert(endPoint: ee)
            .sink(receiveCompletion: { _ in exp.fulfill() }, receiveValue: {})
            .store(in: &cancellables)

        wait(for: [exp], timeout: 3)
    }
}
