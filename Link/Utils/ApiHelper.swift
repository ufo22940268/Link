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

extension Api: Hashable {}

typealias Path = [String]

struct ApiHelper {
    var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAndUpdateEntity(endPoint: EndPointEntity) -> AnyPublisher<[ApiEntity], Error> {
        let reqDate = Date()

        return URLSession(configuration: .ephemeral).dataTaskPublisher(for: URL(string: endPoint.url ?? "")!)
            .receive(on: DispatchQueue.main)
            .tryMap {
                let duration = Date().timeIntervalSince(reqDate)
                endPoint.duration = duration
                endPoint.data = $0.data
                if let response = $0.response as? HTTPURLResponse {
                    endPoint.statusCode = Int16(response.statusCode)
                }
                return try JSON(data: $0.data)
            }
            .map { self.convertToAPI(json: $0) }
            .map {
                self.convertToApiEntity(endPoint: endPoint, apis: $0)
            }
            .tryCatch { _ in
                Just([])
            }
            .eraseToAnyPublisher()
    }

    func test(url: String) -> AnyPublisher<ValidateURLResult, Never> {
        if let urlObj = URL(string: url) {
            let cancellable = URLSession.shared.dataTaskPublisher(for: urlObj)
                .tryMap { ar in
                    let errorLog = ResponseLog(data: ar.0, response: ar.1)
                    if !ar.response.ok {
                        return ValidateURLResult.requestError(errorLog)
                    }

                    if (try JSON(data: ar.data)).count > 0 {
                        return ValidateURLResult.ok
                    } else {
                        return ValidateURLResult.jsonError(errorLog)
                    }
                }
                .catch { error -> AnyPublisher<ValidateURLResult, Never> in
                    if let error = error as? URLError {
                        return Just(ValidateURLResult.requestError(ResponseLog(error: error))).eraseToAnyPublisher()
                    } else {
                        return Just(ValidateURLResult.formatError).eraseToAnyPublisher()
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
        var apiEntities: [ApiEntity] = endPoint.apis

        apiEntities.filter { entity in !apis.contains { $0.path == entity.paths }}
            .forEach { context.delete($0) }

        for api in apis {
            if let index = apiEntities.firstIndex(where: { $0.paths == api.path }) {
                apiEntities[index].value = api.value
            } else {
                let ae = ApiEntity(context: context)
                ae.paths = api.path
                ae.value = api.value
                ae.watch = false
                ae.endPoint = endPoint
                apiEntities.append(ae)
            }
        }

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
