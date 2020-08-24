//
//  EndpointFetchHelper.swift
//  Link
//
//  Created by Frank Cheng on 2020/7/21.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import CoreData
import Foundation

public struct Api: Identifiable {
    public var id: String {
        path
    }

    var paths: [String] {
        path.split(separator: ".").map { String($0) }
    }

    var path: String
    var value: String?
    var watch: Bool = false
}

extension Api: Hashable {
}

typealias Path = [String]

struct ApiHelper {
    var persistentContainer: NSPersistentContainer = getPersistentContainer()
    func fetch(endPoint: EndPointEntity) -> AnyPublisher<[ApiEntity], Error> {
        return URLSession(configuration: .ephemeral).dataTaskPublisher(for: URL(string: endPoint.url ?? "")!)
            .receive(on: DispatchQueue.main)
            .tryMap {
                endPoint.data = $0.data
//                try! self.persistentContainer.viewContext.save()
                return try JSON(data: $0.data)
            }
            .map { self.convertToAPI(json: $0) }
            .map { self.convertToApiEntity(endPoint: endPoint, apis: $0) }
            .tryCatch { _ in
                Just([])
            }
            .eraseToAnyPublisher()
    }

    func test(url: String) -> AnyPublisher<ValidateURLResult, Never> {
        if let urlObj = URL(string: url) {
            let cancellable = URLSession.shared.dataTaskPublisher(for: urlObj)
                .tryMap { ar in
                    if !ar.response.ok {
                        return ValidateURLResult.requestError
                    }

                    if (try JSON(data: ar.data)).count > 0 {
                        return ValidateURLResult.ok
                    } else {
                        return ValidateURLResult.jsonError
                    }
                }
                .catch { error -> AnyPublisher<ValidateURLResult, Never> in
                    if error is URLError {
                        return Just(ValidateURLResult.requestError).eraseToAnyPublisher()
                    } else {
                        return Just(ValidateURLResult.jsonError).eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
            return cancellable
        } else {
            return Just(ValidateURLResult.pending).eraseToAnyPublisher()
        }
    }

    func convertToAPI(json: JSON) -> [Api] {
        var r = traverseJson(json: json, path: [])
        r.sort { l, r in l.path > r.path }
        return r
    }

    func convertToApiEntity(endPoint: EndPointEntity, apis: [Api]) -> [ApiEntity] {
        let req = persistentContainer.managedObjectModel.fetchRequestFromTemplate(withName: "FetchApiByDomain", substitutionVariables: ["endPoint": endPoint.objectID])
        var apiEntities: [ApiEntity] = try! persistentContainer.viewContext.fetch(req!) as! [ApiEntity]

        let context = persistentContainer.viewContext
        for api in apis {
            if let index = apiEntities.firstIndex(where: { $0.paths == api.path }) {
                apiEntities[index].value = api.value
            } else {
                let ae = ApiEntity(context: context)
                ae.paths = api.path
                ae.value = api.value
                ae.endPoint = endPoint
                apiEntities.append(ae)
            }
        }
        try? context.save()

        return apiEntities.sorted { $0.paths ?? "" < $1.paths ?? "" }
    }

    private func traverseJson(json: JSON, path: Path) -> [Api] {
        var j: JSON = json
        if let ar = json.array, ar.count > 0 {
            j = ar[0]
        }

        if let dict = j.dictionary {
            let ar = dict.map { args in
                self.traverseJson(json: args.value, path: path + [args.key])
            }.flatMap { $0 }
            return ar
        }
        return [Api(path: path.joined(separator: "."), value: json.stringValue)]
    }
}
