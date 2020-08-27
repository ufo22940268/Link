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
    @Published var apis = [ApiEntity]()
    @Published var domainName: String = ""
    @Published var url: String = "" {
        didSet {
            if let endPoint = endPoint {
                endPoint.url = url
            }
        }
    }

    var endPoint: EndPointEntity? {
        didSet {
            if let endPoint = endPoint {
                self.apis = endPoint.apis
                self.url = endPoint.url!
                self.domainName = DataSource.default.getDomainName(for: endPoint.url!)
            }
        }
    }

    var endPointId: NSManagedObjectID

    // For create
    init() {
        self.endPoint = EndPointEntity(context: Context.edit)
        self.endPointId = self.endPoint!.objectID
    }

    // For edit
    init(endPointId: NSManagedObjectID) {
        self.endPointId = endPointId
    }
}
