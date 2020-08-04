//
//  DebugHelper.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/1.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import CoreData
import Foundation

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
        
        d.endPoints?.adding(p)

        let a1 = ApiEntity(context: context)
        a1.endPoint = p
        a1.paths = "followers_url"
        a1.watchValue = "https://api.github.com/user/followers"
        a1.watch = true

        p.addToApi(a1)

//        let d2 = EndPointEntity(context: context)
//        d2.name = "a2"
//        d2.url = "https://github.com/ffefef"
        try! context.save()
    }
}
