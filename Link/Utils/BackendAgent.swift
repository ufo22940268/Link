//
//  BackendAgent.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/6.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
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
    static let notLogin = ResponseError(message: "not_login")
}

// MARK: Apis

class BackendAgent {
    static let backendDomain = "http://biubiubiu.hopto.org:3000"
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

    func login(loginInfo: LoginInfo) throws -> AnyPublisher<Void, Never> {
        try post(endPoint: "/user/login",
                 data: ["appleUserId": loginInfo.appleUserId, "notificationToken": LoginManager.getNotificationToken() ?? "", "username": loginInfo.username],
                 options: .login)
            .map { _ in () }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }

    func upload(notificationToken: String) throws -> AnyPublisher<Void, Never> {
        try post(endPoint: "/user/update/notificationtoken", data: ["notificationToken": notificationToken])
            .map { _ in () }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }

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
        return try post(endPoint: "/endpoint/upsert", data: json)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func deleteEndPoint(by url: String) throws -> AnyPublisher<Void, ResponseError> {
        try post(endPoint: "/endpoint/delete", data: ["url": url])
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

// MARK: ScanLog API

extension BackendAgent {
    var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        return decoder
    }

    func listScanLogs() throws -> AnyPublisher<[DurationHistoryItem], ResponseError> {
        get(endPoint: "/scanlog/list").map { json in
            json["result"].arrayValue.map { (json) -> DurationHistoryItem in
                let item = DurationHistoryItem(id: json["id"].string ?? "", url: json["url"].string!, time: json["time"].string!.toDate()!, duration: json["duration"].double ?? 0)
                return item
            }
        }.eraseToAnyPublisher()
    }

    func getScanLog(id: String) throws -> AnyPublisher<RecordItem, ResponseError> {
        get(endPoint: "/scanlog/\(id)").tryMap { json throws in
            try self.jsonDecoder.decode(RecordItem.self, from: json.result.rawData())
        }
        .print()
        .mapError({ (e) -> ResponseError in
            if let e = e as? ResponseError {
                return e
            } else {
                return ResponseError.parseError
            }
        })
        .eraseToAnyPublisher()
    }
}

// MARK: Utils

extension BackendAgent {
    private func get(endPoint: String, options: RequestOptions = []) -> AnyPublisher<Response, ResponseError> {
        if UIDevice.isPreview {
            return Just(JSON()).setFailureType(to: ResponseError.self).eraseToAnyPublisher()
        }

        let url = (URL(string: Self.backendDomain)!.appendingPathComponent(endPoint))
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue(loginInfo!.appleUserId, forHTTPHeaderField: "apple-user-id")
        return URLSession.shared.dataTaskPublisher(for: req)
            .convertToJSON()
    }

    private func post(endPoint: String, data: [String: Any], options: RequestOptions = []) throws -> AnyPublisher<Response, ResponseError> {
        try post(endPoint: endPoint, data: try JSONSerialization.data(withJSONObject: data, options: []), options: options)
    }

    private func post(endPoint: String, data: JSON, options: RequestOptions = []) throws -> AnyPublisher<Response, ResponseError> {
        try post(endPoint: endPoint, data: try data.rawData(), options: options)
    }

    private func post(endPoint: String, data: Data?, options: RequestOptions = []) throws -> AnyPublisher<Response, ResponseError> {
        let url = (URL(string: Self.backendDomain)?.appendingPathComponent(endPoint))!
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
