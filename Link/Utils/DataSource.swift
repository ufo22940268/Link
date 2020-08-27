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

    static let `default`: DataSource = DataSource()

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    init() {
        self.context = getPersistentContainer().viewContext
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
        deleteDomain(for: endPoint.url!)

        endPoint.apis.forEach { context.delete($0) }

        try! context.save()
    }
}

extension DataSource {
    func getDomain(by hostname: String) -> DomainEntity? {
        let req: NSFetchRequest<DomainEntity> = DomainEntity.fetchRequest()
        req.predicate = NSPredicate(format: "hostname == %@", hostname)
        return try? context.fetch(req).first
    }

    func upsertDomainName(name: String, url: String) {
        if let domain = getDomain(by: url.hostname) {
            domain.name = name
        } else {
            let domain = DomainEntity(context: context)
            domain.hostname = url.hostname
            domain.name = name
        }
    }

    func deleteDomain(for url: String) {
        let domain = getDomain(by: url.hostname)
        context.delete(domain!)
    }

    func getDomainName(for url: String) -> String {
        getDomain(by: url.hostname)?.name ?? ""
    }
}

struct Context {
    static let main = getPersistentContainer().viewContext
    static let edit: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = Context.main
        return context
    }()
}
