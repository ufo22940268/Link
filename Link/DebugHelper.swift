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

class DebugHelper {
    static func resetCoreData() {
        print("resetCoreData")

        let context = getPersistentContainer().viewContext
        let entities = [ApiEntity.self, EndPointEntity.self]
        for entity in entities {
            for e in try! context.fetch(entity.fetchRequest()) {
                context.delete(e as! NSManagedObject)
            }
        }
        
        let d = DomainEntity(context: context)
        d.name = "d"
        d.status = HealthStatus.error.rawValue

        let p = EndPointEntity(context: context)
        p.url = "http://biubiubiu.hopto.org:9000/link/github.json"
        p.domain = d
        p.data = NSDataAsset(name: "github", bundle: .main)!.data
        
        d.endPoints?.adding(p)
        
        let p2 = EndPointEntity(context: context)
        p2.url = "http://biubiubiu.hopto.org:9000/link/github.json2"
        p2.domain = d
        p2.data = NSDataAsset(name: "fireball", bundle: .main)!.data

        d.endPoints?.adding(p2)

        let a1 = ApiEntity(context: context)
        a1.endPoint = p
        a1.paths = "followers_url"
        a1.watchValue = "https://api.github.com/user/followers"
        a1.watch = true

        p.addToApi(a1)

        try! context.save()
    }
    
    static var isPreview: Bool  {
       (ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] ?? "") == "1"
    }
}
