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

    func deleteEndPoint(entity endPoint: EndPointEntity) {
        context.delete(fetchEndPoint(id: endPoint.objectID)!)
        if let endPoints = endPoint.domain?.endPoints, !endPoints.contains(where: { ($0 as? EndPointEntity) != endPoint }) {
            context.delete(endPoint.domain!)
        }
        endPoint.apis.forEach { context.delete($0) }
        
        try! context.save()
    }
}
