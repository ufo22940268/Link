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
        context = getPersistentContainer().viewContext
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

    func fetchEndPoints() -> [EndPointEntity]? {
        let req = EndPointEntity.fetchRequest() as NSFetchRequest<EndPointEntity>
        return try? context.fetch(req)
    }

    func deleteEndPoint(entity endPoint: EndPointEntity) {
        let url = endPoint.url ?? ""
        context.delete(fetchEndPoint(id: endPoint.objectID)!)

        endPoint.apis.forEach { context.delete($0) }

        let req = EndPointEntity.fetchRequest() as NSFetchRequest<EndPointEntity>
        if let ees = try? context.fetch(req), ees.filter({ $0.url?.hostname == url.hostname }).count == 0 {
            deleteDomain(for: url)
        }

        try! context.save()
    }
}

extension DataSource {
    func updateLastTime() {
        var entity: LastUpdateEntity
        if let e = try? context.fetchOne(LastUpdateEntity.self) {
            entity = e
        } else {
            entity = LastUpdateEntity(context: CoreDataContext.main)
        }
        entity.time = Date()
        try! context.save()
    }

    func getLastUpdatedTime() -> Date? {
        try? context.fetchOne(LastUpdateEntity.self)?.time
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
        if let domain = getDomain(by: url.hostname) {
            context.delete(domain)
        }
    }

    func getDomainName(for url: String) -> String {
        getDomain(by: url.hostname)?.name ?? ""
    }

    func isURLExists(_ url: String) -> Bool {
        let req = EndPointEntity.fetchRequest() as NSFetchRequest<EndPointEntity>
        req.predicate = NSPredicate(format: "url == %@", url)
        return (try? context.fetch(req).first) != nil
    }
}

struct CoreDataContext {
    static let main = getPersistentContainer().viewContext
    static let edit: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.name = "edit"
        context.parent = CoreDataContext.main
        return context
    }()

    static let add: NSManagedObjectContext = createChildContext(name: "add")

    private static func createChildContext(name: String) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.name = name
        context.parent = CoreDataContext.main
        return context
    }
}

extension NSManagedObjectContext {
    func fetchMany<T>(_ type: T.Type, _ format: String? = nil, _ argList: String...) throws -> [T] where T: NSManagedObject {
        let req = T.fetchRequest() as! NSFetchRequest<T>
        if let format = format {
            req.predicate = NSPredicate(format: format, argumentArray: argList)
        }
        do {
            return try fetch(req)
        } catch {
            throw error
        }
    }

    func fetchOne<T>(_ type: T.Type, _ format: String? = nil, _ argList: CVarArg...) throws -> T? where T: NSManagedObject {
        let req = T.fetchRequest() as! NSFetchRequest<T>
        if let format = format {
            req.predicate = NSPredicate(format: format, argumentArray: argList)
        }

        do {
            return try fetch(req).first
        } catch {
            throw error
        }
    }
}
