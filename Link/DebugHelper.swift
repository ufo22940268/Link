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
        let entities = [ApiEntity.self, DomainEntity.self]
        for entity in entities {
            for e in try! context.fetch(entity.fetchRequest()) {
                context.delete(e as! NSManagedObject)
            }
        }
        
        let d = DomainEntity(context: context)
        d.name = "a"
        d.url = "http://biubiubiu.hopto.org:9000/"
        let d2 = DomainEntity(context: context)
        d2.name = "a2"
        d2.url = "https://github.com/"
        try! context.save()
    }
}
