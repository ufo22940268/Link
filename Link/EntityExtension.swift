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
    
    var status: HealthStatus {
        if let apis = api?.allObjects as? [ApiEntity] {
            if apis.allSatisfy({ $0.watch == false }) {
                return .other
            }
            
            let errorApis = apis.filter{ $0.watch && $0.value != $0.watchValue }
            if errorApis.count > 0 {
                return .error
            } else {
                return .healthy
            }
        }
        
        return .other
    }
    
    var apis: [ApiEntity] {
        guard let apis = api?.allObjects as? [ApiEntity] else {
            return []
        }

        return apis
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


