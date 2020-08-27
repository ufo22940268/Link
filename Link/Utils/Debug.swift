//
//  DebugHelper.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/1.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import CoreData
import Foundation
import SwiftUI

public class DebugHelper {
    fileprivate static func addMockEndPoint2(_ context: NSManagedObjectContext, _ d: DomainEntity) {
        let p2 = EndPointEntity(context: context)
        p2.url = "http://biubiubiu.hopto.org:9000/link/github.json2"
        p2.data = NSDataAsset(name: "fireball", bundle: .main)!.data

        let a1 = ApiEntity(context: context)
        a1.endPoint = p2
        a1.paths = "followers_url"
        a1.watchValue = "https://api.github.com/user/followers"
        a1.watch = false

        let a2 = ApiEntity(context: context)
        a2.endPoint = p2
        a2.paths = "feeds_url"
        a2.watchValue = "https://api.github.com/user/feeds"
        a2.watch = true

        p2.addToApi(a1)
        p2.addToApi(a2)
    }

    fileprivate static func clearDB(_ context: NSManagedObjectContext) {
        let entities = [ApiEntity.self, EndPointEntity.self, DomainEntity.self]
        for entity in entities {
            for e in try! context.fetch(entity.fetchRequest()) {
                context.delete(e as! NSManagedObject)
            }
        }
    }

    static func resetCoreData() {
        print("resetCoreData")
        let context = getPersistentContainer().viewContext
        clearDB(context)

        let d = DomainEntity(context: context)
        d.name = "d9"
        d.hostname = "biubiubiu.hopto.org:9000"
//
        let p = EndPointEntity(context: context)
        p.url = "http://biubiubiu.hopto.org:9000/link/fb.json"
        p.data = NSDataAsset(name: "github", bundle: .main)!.data
//
//        addMockEndPoint2(context, d)

        try! context.save()
    }

    static var isPreview: Bool {
        (ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] ?? "") == "1"
    }
}

public extension UIDevice {
    static var isSimulator: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()

    static var isRunningTest: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}

public extension String {
    func randomStr(length: Int = 5) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< length).map { _ in letters.randomElement()! })
    }
}