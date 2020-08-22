//
//  DataSource.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/13.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import CoreData
import Foundation

final class DataSource: ObservableObject {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

// MARK: EndPoints api

extension DataSource {
    func fetchEndPoint(id: NSManagedObjectID) -> EndPointEntity? {
        let req = EndPointEntity.fetchRequest() as NSFetchRequest<EndPointEntity>
        req.predicate = NSPredicate(format: "self == %@", id)
        return try? context.fetch(req).first
    }

    func fetchEndPoint(url: String) -> EndPointEntity? {
        let req = EndPointEntity.fetchRequest() as NSFetchRequest<EndPointEntity>
        req.predicate = NSPredicate(format: "url == %@", url)
        return try? context.fetch(req).first
    }
}
