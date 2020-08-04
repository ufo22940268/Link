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

    func checkHealth(_ result: ([EndPointEntity]) -> Void) -> AnyPublisher<Void, URLError> {
        let pubs = domains.map { checkUrl(for: $0) }
        return Publishers.MergeMany(pubs).map{_ in }.eraseToAnyPublisher()
    }

    func checkUrl(for domain: EndPointEntity) -> AnyPublisher<(), URLError> {
        return ApiHelper().fetch(endPoint: domain).map { apis in
            if apis.contains(where: { $0.watch && $0.value != $0.watchValue }) {
                domain.status = HealthStatus.error.rawValue
            }
        }
        .eraseToAnyPublisher()
    }
}
