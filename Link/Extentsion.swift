//
//  Extentsions.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/2.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import CoreData
import  SwiftUI


extension PreviewProvider {
    static var context: NSManagedObjectContext {
        getPersistentContainer().viewContext
    }
}
