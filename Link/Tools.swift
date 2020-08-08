//
//  Tools.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/20.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation
import CoreData
import UIKit

func extractDomainName(fromURL:  String) -> String {    
    let regex = try? NSRegularExpression(pattern: "((http|https)://)?(\\w+\\.)?(?<dn>(\\w)+)\\.", options: [])
    if let match = regex?.firstMatch(in: fromURL, options: [], range: NSRange(location: 0, length: fromURL.utf16.count)) {
        if let domainNameRange = Range(match.range(withName: "dn"), in: fromURL)  {
            return String(fromURL[domainNameRange])
        }
    }
    return ""
}


func getPersistentContainer() -> NSPersistentContainer {
    return (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer
}


func getAnyEndPoint() throws -> EndPointEntity {
    var domain: EndPointEntity
    let persistentContainer = getPersistentContainer()
    do {
        let req: NSFetchRequest<EndPointEntity> = EndPointEntity.fetchRequest();
        req.predicate = NSPredicate(format: "url==%@", "http://biubiubiu.hopto.org:9000/link/github.json")
        let ds = try? persistentContainer.viewContext.fetch(req)
        if let ds = ds, ds.count >= 1 {
            domain = ds.first!
        } else {
            throw "Domain not founed"
        }
        return domain
    } catch {
        throw error
    }
}

struct URLHelper {    
    static func extractEndPointPath(url: String) -> String {
        let regex = try? NSRegularExpression(pattern: "((http|https)://)?(\\w+\\.)?(?<dn>(\\w)+)\\.[^/]+/(?<pa>.+)", options: [])
        if let match = regex?.firstMatch(in: url, options: [], range: NSRange(location: 0, length: url.utf16.count)) {
            if let domainNameRange = Range(match.range(withName: "pa"), in: url)  {
                return String(url[domainNameRange])
            }
        }
        return ""

    }
}
