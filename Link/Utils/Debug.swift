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
    static func resetCoreData() {
        print("resetCoreData")

        let context = getPersistentContainer().viewContext
        let entities = [ApiEntity.self, EndPointEntity.self, DomainEntity.self]
        for entity in entities {
            for e in try! context.fetch(entity.fetchRequest()) {
                context.delete(e as! NSManagedObject)
            }
        }

        let d = DomainEntity(context: context)
        d.name = "d"

        let p = EndPointEntity(context: context)
        p.url = "http://biubiubiu.hopto.org:9000/link/fb.json"
        p.domain = d
        p.data = NSDataAsset(name: "github", bundle: .main)!.data

        d.endPoints?.adding(p)

        let p2 = EndPointEntity(context: context)
        p2.url = "http://biubiubiu.hopto.org:9000/link/github.json2"
        p2.domain = d
        p2.data = NSDataAsset(name: "fireball", bundle: .main)!.data

        d.endPoints?.adding(p2)
        

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
}
