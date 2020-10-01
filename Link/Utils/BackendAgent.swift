//
//  BackendAgent.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/6.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import CoreData
import Foundation
import UIKit

typealias Response = JSON

struct ResponseError: Error {
    internal init(json: JSON? = nil) {
        self.json = json
    }

    internal init(error: Error) {
        self.error = error
    }

    internal init(message: String) {
        self.message = message
    }

    var json: JSON?
    var error: Error?
    var message: String?

    static let parseError = ResponseError(message: "parse_error")
    static let parseJSONError = ResponseError(message: "parse_json_error")
    static let notLogin = ResponseError(message: "not_login")
}

// MARK: Apis

struct BackendAgent {
    static let backendDomain = UIDevice.apiEnv.domain
    var loginInfo: LoginInfo? {
        LoginManager.getLoginInfo()
    }

    var isLogin: Bool {
        loginInfo != nil
    }

    init() {}

    struct RequestOptions: OptionSet {
        let rawValue: Int

        static let login = RequestOptions(rawValue: 1 << 0)
    }

    var debug = ProcessInfo.processInfo.environment["PROFILE_REQUEST"] != nil

    func login(loginInfo: LoginInfo) throws -> AnyPublisher<Void, ResponseError> {
        post(endPoint: "/user/login",
             data: ["appleUserId": loginInfo.appleUserId, "notificationToken": LoginManager.getNotificationToken() ?? "", "username": loginInfo.username],
             options: .login)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func upload(notificationToken: String) throws -> AnyPublisher<Void, Never> {
        post(endPoint: "/user/update/notificationtoken", data: ["notificationToken": notificationToken])
            .map { _ in () }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }
}

// MARK: EndPoint  API

extension BackendAgent {
    func upsert(endPoint: EndPointEntity) throws -> AnyPublisher<Void, ResponseError> {
        if loginInfo == nil {
            throw ResponseError.notLogin
        }
        var json = JSON()
        json["url"].string = endPoint.url!
        if let apis = endPoint.api?.allObjects.map({ $0 as! ApiEntity }) {
            json["watchFields"].arrayObject = apis.filter { $0.watch }.map { api in
                ["value": api.watchValue, "path": api.paths]
            }
        }
        return post(endPoint: "/endpoint/upsert", data: json)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func sync(endPoints: [EndPointEntity]) -> AnyPublisher<Void, ResponseError> {
        var json = JSON()
        json.arrayObject = [JSON]()
        for endPoint in endPoints {
            var ej = JSON()
            ej["url"].string = endPoint.url!
            if let apis = endPoint.api?.allObjects.map({ $0 as! ApiEntity }) {
                ej["watchFields"].arrayObject = apis.filter { $0.watch }.map { api in
                    ["value": api.watchValue, "path": api.paths]
                }
            }
            json.arrayObject!.append(ej)
        }
        return post(endPoint: "/endpoint/sync", data: json)
            .eraseToVoidAnyPublisher()
    }

    private func ensureHostName(endPoint: EndPointEntity, context: NSManagedObjectContext) {
        guard let url = endPoint.url else { return }
        let req = DomainEntity.fetchRequest() as NSFetchRequest<DomainEntity>
        req.predicate = NSPredicate(format: "hostname == %@", url.hostname)
        let domain = try? context.fetch(req).first
        if domain == nil {
            let domain = DomainEntity(context: context)
            domain.hostname = url.hostname
            domain.name = url.domainName
        }
    }

    func syncFromServer(context: NSManagedObjectContext) -> AnyPublisher<Void, ResponseError> {
        get(endPoint: "/endpoint/sync/list")
            .parseArrayObjects(to: EndPoint.self)
            .receive(on: DispatchQueue.main)
            .map { (endPoints: [EndPoint]) in
                let req = EndPointEntity.fetchRequest() as NSFetchRequest<EndPointEntity>
                req.predicate = NSPredicate(format: "url IN %@", endPoints.map { $0.url })
                if let exists: [EndPointEntity] = try? context.fetch(req) {
                    let newEndPointEntities = endPoints.filter { e in
                        !exists.map { $0.url! }.contains(e.url)
                    }

                    _ = newEndPointEntities.map {
                        let entity = $0.toEntity(context: context)
                        ensureHostName(endPoint: entity, context: context)
                    }
                }
                try! context.save()
            }
            .eraseToAnyPublisher()
    }

    func deleteEndPoint(by url: String) throws -> AnyPublisher<Void, ResponseError> {
        post(endPoint: "/endpoint/delete", data: ["url": url])
            .eraseToVoidAnyPublisher()
    }
}

// MARK: ScanLog API

extension BackendAgent {
    var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        return decoder
    }

    func getScanLogs(timeSpan: TimeSpan) throws -> AnyPublisher<[ScanLog], ResponseError> {
        get(endPoint: "/scanlog/list", query: ["timeSpan": timeSpan.rawValue]).map { json in
            json["result"].arrayValue.map { (json) -> ScanLog in
                let item = ScanLog(id: json["id"].string ?? "", url: json["url"].string!, time: json["time"].string!.toDate()!, duration: json["duration"].double ?? 0, errorCount: json["errorCount"].int ?? 0, endPointId: json["endPointId"].string!)
                return item
            }
        }.eraseToAnyPublisher()
    }

    func getScanLogs(by endPointId: String) -> AnyPublisher<[ScanLogDetail], ResponseError> {
        get(endPoint: "/scanlog/list/\(endPointId)")
            .parseArrayObjects(to: ScanLogDetail.self)
            .eraseToAnyPublisher()
    }

    func getScanLog(id: String) -> AnyPublisher<RecordItem, ResponseError> {
        get(endPoint: "/scanlog/\(id)").map { json in
            try! self.jsonDecoder.decode(RecordItem.self, from: json.result.rawData())
        }
        .eraseToAnyPublisher()
    }

    func runScanLogTask() -> AnyPublisher<Void, ResponseError> {
        post(endPoint: "/endpoint/scan")
            .map { _ in }
            .eraseToAnyPublisher()
    }
}

// MARK: Utils

extension BackendAgent {
    private func get(endPoint: String, query: [String: Any] = [:], options: RequestOptions = []) -> AnyPublisher<Response, ResponseError> {
        if UIDevice.isPreview {
            return Just(JSON()).setFailureType(to: ResponseError.self).eraseToAnyPublisher()
        }

        var url = (URL(string: Self.backendDomain)!.appendingPathComponent(endPoint))
        url = url.appending("token", value: loginInfo!.appleUserId)
        for (k, v) in query {
            url = url.appending(k, value: String(describing: v))
        }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        return URLSession.shared.dataTaskPublisher(for: req)
            .convertToJSON()
    }

    private func post(endPoint: String, data: [String: Any] = [:], options: RequestOptions = []) -> AnyPublisher<Response, ResponseError> {
        try! post(endPoint: endPoint, data: try JSONSerialization.data(withJSONObject: data, options: []), options: options)
    }

    private func post(endPoint: String, data: JSON, options: RequestOptions = []) -> AnyPublisher<Response, ResponseError> {
        try! post(endPoint: endPoint, data: try data.rawData(), options: options)
    }

    private func post(endPoint: String, data: Data?, options: RequestOptions = []) throws -> AnyPublisher<Response, ResponseError> {
        var url = (URL(string: Self.backendDomain)?.appendingPathComponent(endPoint))!
        url = url.appending("token", value: loginInfo!.appleUserId)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        if let data = data {
            req.httpBody = data
        }
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if !options.contains(.login) {
            req.setValue(loginInfo!.appleUserId, forHTTPHeaderField: "apple-user-id")
        }

        var debugInfo = ""
        if debug {
            debugInfo = debugInfo + """
            =====================request start======================
            url: \(url)
            request: \(String(describing: String(data: data!, encoding: .utf8)))
            """
        }

        return URLSession.shared.dataTaskPublisher(for: req)
            .handleEvents(receiveOutput: { data, _ in
                if self.debug {
                    debugInfo = debugInfo + """

                    response: \(String(data: data, encoding: .utf8) ?? "")
                    =====================end======================
                    """
                    print(debugInfo)
                }
            })
            .convertToJSON()
    }
}
