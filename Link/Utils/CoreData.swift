//
//  CoreData.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/27.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation
import CoreData


extension NSManagedObjectContext {
    
    func saveToDB() throws {
        try save()
        if let parent = parent {
            try parent.save()
        }
    }
}
