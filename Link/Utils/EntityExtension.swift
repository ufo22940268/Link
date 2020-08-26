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
        url ?? ""
    }

    var endPointPath: String {
        return URLHelper.extractEndPointPath(url: url ?? "")
    }

    var status: HealthStatus {
        if let data = data, !data.isValidJSON {
            return .formatError
        }

        if let apis = api?.allObjects as? [ApiEntity] {
            if apis.allSatisfy({ $0.watch == false }) {
                return .other
            }

            let errorApis = apis.filter { $0.watch && $0.value != $0.watchValue }
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

        return apis.sorted { $0.paths ?? "" < $1.paths ?? "" }
    }

    var isCompleted: Bool {
        return statusCode != 0
    }
}

extension ApiEntity: Identifiable {
    public var id: String {
        objectID.uriRepresentation().absoluteString
    }

    var match: Bool {
        guard let watchValue = watchValue, let value = value, watch else { return false }
        return watchValue == value
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
