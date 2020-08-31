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
    @Published var apis = [ApiEntity]() {
        didSet {
            apis.forEach {
                $0.objectWillChange.sink {
                    self.objectWillChange.send()
                }
                .store(in: &cancellables)
            }
        }
    }

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

    // For create
    init() {}

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

    func setEndPointForCreate() {
        self.endPoint = EndPointEntity(context: CoreDataContext.edit)
        self.endPointId = self.endPoint!.objectID
        self.domainName = ""
        self.url = ""
    }
}
