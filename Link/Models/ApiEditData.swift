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
    @Published var url: String = ""

    var endPoint: EndPointEntity?

    // For create
    init() {
        self.endPoint = EndPointEntity()
    }

    // For edit
    init(endPoint: EndPointEntity) {
        self.apis = endPoint.apis
        self.domainName = DataSource.default.getDomainName(for: endPoint.url!)
        self.url = endPoint.url ?? ""
        self.endPoint = endPoint
    }
}
