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

extension String {
    subscript(_ range: NSRange) -> String {
        let start = self.index(self.startIndex, offsetBy: range.lowerBound)
        let end = self.index(self.startIndex, offsetBy: range.upperBound)
        let subString = self[start..<end]
        return String(subString)
    }
}
    

extension String: Error {}
