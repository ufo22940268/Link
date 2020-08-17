//
//  HealthChecker.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import Foundation

var c: Cancellable?

struct HealthChecker {
    var domains: [EndPointEntity]

    func checkHealth() -> AnyPublisher<Void, Error> {
        let pubs = domains.map { checkUrl(for: $0) }
        return Publishers.MergeMany(pubs).collect().map { _ in }.eraseToAnyPublisher()
    }

    func checkUrl(for endpoint: EndPointEntity) -> AnyPublisher<Void, Error> {
        return ApiHelper()
            .fetch(endPoint: endpoint)
            .filter({ apis in
                apis.contains(where: { $0.watch && $0.value != $0.watchValue })
            })
            .collect()
            .map({ errorApis in
                if errorApis.count > 0 {
                    endpoint.status = HealthStatus.error.rawValue
                } else {
                    endpoint.status = HealthStatus.healthy.rawValue
                }
            })
            .eraseToAnyPublisher()
    }
}
