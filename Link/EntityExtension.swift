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

extension ApiEntity: Identifiable {
    public var id: String {
        self.objectID.uriRepresentation().absoluteString
    }

    var healthyStatus: HealthStatus? {
        guard let watchValue = self.watchValue, self.watch else { return nil }
        
        if watchValue == value {
            return .healthy
        } else {
            return .error
        }
    }
}


