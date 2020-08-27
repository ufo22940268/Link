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
            endPoint.url = url
        }
    }

    var endPoint: EndPointEntity

    // For create
    init() {
        self.endPoint = EndPointEntity(context: getPersistentContainer().viewContext)
    }

    // For edit
    init(endPoint: EndPointEntity) {
        self.endPoint = endPoint
        self.apis = endPoint.apis
        self.domainName = DataSource.default.getDomainName(for: endPoint.url!)
        self.url = endPoint.url ?? ""
    }
}
