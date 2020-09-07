//
//  DomainData.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/3.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

final class DomainData: ObservableObject {
    @Published var endPoints: [EndPointEntity] = []
    @Published var isLoading = false
    @Published var lastUpdateTime: Date?
    var cancellables = [AnyCancellable]()

    var needReload = PassthroughSubject<Void, Never>()

    func healthyCount() -> Int {
        endPoints.filter { $0.status == HealthStatus.healthy }.count
    }

    func errorCount() -> Int {
        endPoints.filter { $0.status == HealthStatus.error }.count
    }

    func findEndPointEntity(by id: NSManagedObjectID) -> EndPointEntity? {
        endPoints.first { $0.objectID == id }
    }

    static func test(context: NSManagedObjectContext) -> DomainData {
        let req: NSFetchRequest<EndPointEntity> = EndPointEntity.fetchRequest()
        req.predicate = NSPredicate(format: "url == %@", "http://biubiubiu.hopto.org:9000/link/github.json")
        let dd = DomainData()
        dd.endPoints = try! context.fetch(req)
        return dd
    }

    func deleteEndPoint(by url: String) {
        let agent = BackendAgent()
        try? agent.deleteEndPoint(by: url)
            .sink(receiveCompletion: { _ in }, receiveValue: {})
            .store(in: &cancellables)
    }
}

final class EndPointData: ObservableObject {
    @Published var endPoint: EndPointEntity

    init(endPoint: EndPointEntity) {
        self.endPoint = endPoint
    }
}
