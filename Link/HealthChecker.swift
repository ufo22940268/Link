//
//  HealthChecker.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation
import Combine

var c: Cancellable? = nil

struct HealthChecker {
    
    var domains: [DomainEntity]
    
    func checkHealth(_ result: ([DomainEntity]) -> Void) {
        for domain in domains {
            checkUrl(for: domain)
        }
    }
    
    func checkUrl(for domain: DomainEntity) {
        c = ApiHelper().fetch(domain: domain).map { apis in
            if apis.contains(where: { $0.watch && $0.value != $0.watchValue }) {
                domain.status = HealthStatus.error.rawValue
            }
        }
        .sink(receiveCompletion: { e in
            print(e)
        }, receiveValue: {
            
        })
    }
}
