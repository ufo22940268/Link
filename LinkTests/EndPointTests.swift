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
import CoreData
@testable import Link

public final class MockedData {
    public static let githubApi: Data = NSDataAsset(name: "github", bundle: .main)!.data
}

//let persistentContainer: NSPersistentContainer = {
//    let container = NSPersistentContainer(name: "LinkModel")
//    container.loadPersistentStores { description, error in
//        if let error = error {
//            fatalError("Unable to load persistent stores: \(error)")
//        }
//    }
//    return container
//}()

class EndPointTests: XCTestCase {
    
    var objectContext: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        
        let originalURL = URL(string: "https://api.github.com")!
        
        let mock = Mock(url: originalURL, dataType: .json, statusCode: 200, data: [
            .get : MockedData.githubApi // Data containing the JSON response
        ])
        mock.register()
        
        self.objectContext = persistentContainer.viewContext
        
        ["DomainEntity", "ApiEntity"].forEach { self.deleteTable($0) }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private func deleteTable(_ tableName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tableName)
        let delReq = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? objectContext.execute(delReq)
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
    
    func testCoreData() {
        let d = Domain(context: objectContext)
        d.name = "ijij"
        
        var ae = ApiEntity(context: objectContext)
        ae.paths = "asdf"
        ae.watch = true
        ae.domain = d

        ae = ApiEntity(context: objectContext)
        ae.paths = "asdf2"
        ae.watch = false
        ae.domain = d
        try! objectContext.save()

        let req: NSFetchRequest<ApiEntity> = NSFetchRequest<ApiEntity>(entityName: "ApiEntity")
        req.predicate = NSPredicate(format: "domain = %@", d.objectID)
        let aes = try? objectContext.fetch(req)
        print(aes)
        
        let ds = try? objectContext.fetch(Domain.fetchRequest())
        print(ds)
    }
}
