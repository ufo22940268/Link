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
    @Published var endPoints: [EndPointEntity] = []
    var onAddedDomain = PassthroughSubject<Void, Never>()
    
    func healthyCount() -> Int {
        return endPoints.filter { $0.status == HealthStatus.healthy.rawValue }.count
    }
    
    func errorCount() -> Int {
        return endPoints.filter { $0.status == HealthStatus.error.rawValue }.count
    }
}

final class EndPointData: ObservableObject {
    @Published var endPoint: EndPointEntity
    
    init(endPoint: EndPointEntity) {
        self.endPoint = endPoint
    }
}


