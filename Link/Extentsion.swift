//
//  Extentsions.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/2.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import CoreData
import SwiftUI

extension PreviewProvider {
    static var context: NSManagedObjectContext {
        let container = NSPersistentContainer(name: "LinkModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }

        return container.viewContext
    }
}

extension String {
    subscript(_ range: NSRange) -> String {
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        let subString = self[start ..< end]
        return String(subString)
    }

    var lastPropertyPath: String {
        if let r = self.range(of: #"(?<=\.)[^\.]+?$"#, options: .regularExpression) {
            return String(self[r])
        } else {
            return self
        }
    }
}

extension Color {
    static let error = Color.red
}

struct EndPointEntityKey: EnvironmentKey {
    static var defaultValue: NSManagedObjectID?
    typealias Value = NSManagedObjectID?
}

extension EnvironmentValues {
    var endPointId: NSManagedObjectID? {
        get {
            self[EndPointEntityKey.self]
        }

        set {
            self[EndPointEntityKey.self] = newValue
        }
    }
}

extension URLResponse {
    var ok: Bool {
        if let res = self as? HTTPURLResponse, (200 ... 299).contains(res.statusCode) {
            return true
        } else {
            return false
        }
    }
}

extension String: Error {}
