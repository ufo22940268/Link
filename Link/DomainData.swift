//
//  DomainData.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/3.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import SwiftUI
import CoreData

final class DomainData: ObservableObject {
    
    @Published var endPoints: [EndPointEntity] = []
    
    var onAddedDomain = PassthroughSubject<Void, Never>()
    
    func healthyCount() -> Int {
        return endPoints.filter { $0.status == HealthStatus.healthy.rawValue }.count
    }
    
    func errorCount() -> Int {
        return endPoints.filter { $0.status == HealthStatus.error.rawValue }.count
    }
    
    static func test(context: NSManagedObjectContext) -> DomainData {
        guard let endPoints = try? context.fetch(EndPointEntity.fetchRequest()) as? [EndPointEntity], endPoints.count > 0 else { fatalError() }
        
        let dd = DomainData()
        dd.endPoints = [endPoints[0]]
        return dd
    }
}

final class EndPointData: ObservableObject {
    @Published var endPoint: EndPointEntity
    
    init(endPoint: EndPointEntity) {
        self.endPoint = endPoint
    }
}


