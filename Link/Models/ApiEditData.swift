//
//  ApiEditData.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/23.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

class ApiEditData: ObservableObject {
    var cancellables = [AnyCancellable]()
    @Published var apis = [ApiEntity]()
    @Published var domainName: String = ""
    @Published var url: String = ""

    var originURL: String?

    var endPoint: EndPointEntity? {
        didSet {
            if let endPoint = endPoint, endPoint.url != nil {
                self.apis = endPoint.apis
                self.url = endPoint.url!
                self.domainName = DataSource.default.getDomainName(for: endPoint.url!)
            }
        }
    }

    var endPointId: NSManagedObjectID?
    var context: NSManagedObjectContext?

    // For create
    init() {
        self.setupForCreate()
    }

    func upsertEndPointInServer() {
        guard let endPoint = endPoint else { return }
        if let c = (try? BackendAgent().upsert(endPoint: endPoint))?.sink(receiveCompletion: { _ in }, receiveValue: {}) {            
            self.cancellables.append(c)
        }
    }

    func setupForCreate() {
        if let c = self.context {
            c.rollback()
        }

        let context = CoreDataContext.add
        self.context = context
        self.endPoint = EndPointEntity(context: context)
        self.endPointId = self.endPoint!.objectID
        self.domainName = ""
        self.url = ""
    }

    var unwatchApis: [ApiEntity] {
        self.apis.filter { !$0.watch }
    }

    var watchApis: [ApiEntity] {
        self.apis.filter { $0.watch }
    }

    // For edit
    init(endPointId: NSManagedObjectID) {
        self.endPointId = endPointId
    }
}
