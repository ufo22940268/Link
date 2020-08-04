//
//  DebugHelper.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/1.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation
import CoreData

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
        
        let d = EndPointEntity(context: context)
        d.url = "http://biubiubiu.hopto.org:9000/link/github.json"
        
        let a1 = ApiEntity(context: context)
        a1.domain = d
        a1.paths = "followers_url"
        a1.watchValue = "https://api.github.com/user/followers1"
        a1.watch = true
        
        d.addToApi(a1)
        
//        let d2 = EndPointEntity(context: context)
//        d2.name = "a2"
//        d2.url = "https://github.com/ffefef"
        try! context.save()
    }
}
