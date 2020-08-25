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

    init() {}

    init(endPoint: EndPointEntity) {
        self.apis = endPoint.apis
        self.domainName = endPoint.domain!.name ?? ""
        self.url = endPoint.url ?? ""
    }
}
