//
//  HealthChecker.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import Foundation
import CoreData

struct HealthChecker {
    internal init(domains: [EndPointEntity], context: NSManagedObjectContext) {
        self.domains = domains
        self.context = context
    }
    
    var domains: [EndPointEntity]
    var context: NSManagedObjectContext

    func checkHealth() -> AnyPublisher<Void, Error> {
        let pubs = domains.map { checkUrl(for: $0) }
        return Publishers.MergeMany(pubs).collect().map { _ in }.eraseToAnyPublisher()
    }

    func checkUrl(for endpoint: EndPointEntity) -> AnyPublisher<Void, Error> {
        return ApiHelper(context: context)
            .fetchAndUpdateEntity(endPoint: endpoint)
            .filter({ apis in
                apis.contains(where: { $0.watch && $0.value != $0.watchValue })
            })
            .collect()
//            .map({ errorApis in
//                if errorApis.count > 0 {
//                    endpoint.status = HealthStatus.error.rawValue
//                } else {
//                    endpoint.status = HealthStatus.healthy.rawValue
//                }
//            })
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
