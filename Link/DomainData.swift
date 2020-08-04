//
//  DomainData.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/3.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import SwiftUI

final class DomainData: ObservableObject {
    @Published var domains: [EndPointEntity] = []
    
    func healthyCount() -> Int {
        return domains.filter { $0.status == HealthStatus.healthy.rawValue }.count
    }
    
    func errorCount() -> Int {
        return domains.filter { $0.status == HealthStatus.error.rawValue }.count
    }
}


