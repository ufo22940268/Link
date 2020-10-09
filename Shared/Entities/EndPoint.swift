//
//  EndPoint.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/23.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import CoreData
import Foundation

struct EndPoint: Codable {
    struct WatchField: Codable {
        var path: String
        var value: String

        func toApiEntity(context: NSManagedObjectContext, ee: EndPointEntity) -> ApiEntity {
            let ae = ApiEntity(context: context)
            ae.endPoint = ee
            ae.watchValue = value
            ae.paths = path
            ae.watch = true
            return ae
        }
    }

    var url: String
    var watchFields: [WatchField]?

    func toEntity(context: NSManagedObjectContext) -> EndPointEntity {
        let ee = EndPointEntity(context: context)
        ee.url = url
        ee.needReload = true

        if let watchFields = watchFields {
            for field in watchFields {
                ee.addToApi(field.toApiEntity(context: context, ee: ee))
            }
        }

        let req = DomainEntity.fetchRequest() as NSFetchRequest<DomainEntity>
        req.predicate = NSPredicate(format: "hostname = %@", argumentArray: [url.domainName])
        if ((try? context.fetch(req).first == nil) != nil) {
            let d = DomainEntity(context: context)
            d.hostname = url.domainName
            d.name = url.domainName
        }

        return ee
    }
}
