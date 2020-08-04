//
//  EntityExtension.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/2.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation


extension EndPointEntity: Identifiable {
    public var id: String {
        self.url ?? ""
    }
    
    var endPointPath: String {
        return URLHelper.extractEndPointPath(url: url ?? "")
    }
}

