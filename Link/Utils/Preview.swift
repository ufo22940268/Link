//
//  Preview.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/26.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import CoreData
import SwiftUI

extension PreviewProvider {
    static var context: NSManagedObjectContext {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return context
    }

    static var testDomain: DomainEntity {
        let domain = DomainEntity(context: context)
        domain.name = "test domain name"
        return domain
    }
    
    static var dataSource: DataSource {
        DataSource(context: context)
    }
}
