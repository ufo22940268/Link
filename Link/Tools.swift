//
//  Tools.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/20.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation
import CoreData

func extractDomainName(fromURL:  String) -> String {
    let regex = try? NSRegularExpression(pattern: "((http|https)://)?(\\w+\\.)?(?<dn>(\\w)+)\\.", options: [])
    if let match = regex?.firstMatch(in: fromURL, options: [], range: NSRange(location: 0, length: fromURL.utf16.count)) {
        if let domainNameRange = Range(match.range(withName: "dn"), in: fromURL)  {
            return String(fromURL[domainNameRange])
        }
    }
    return ""
}


func getAnyDomain() -> Domain {
    var domain: Domain
    do {
        let req: NSFetchRequest<Domain> = Domain.fetchRequest();
        let ds = try? persistentContainer.viewContext.fetch(req)
        if let ds = ds, ds.count == 1 {
            domain = ds.first!
        } else {
            try? persistentContainer.viewContext.execute(NSBatchDeleteRequest(fetchRequest: Domain.fetchRequest()))
            let d = Domain(context: persistentContainer.viewContext)
            d.name = "d"
            try? persistentContainer.viewContext.save()
            domain = d
        }
    } catch {
        print(error)
    }
    return domain
}

