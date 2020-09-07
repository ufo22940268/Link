//
//  BackendAgent.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/6.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import Foundation

class BackendAgent {
    static let backendDomain = "http://biubiubiu.hopto.org:3000"
    var loginInfo: LoginInfo? {
        LoginManager.getLoginInfo()
    }

    var isLogin: Bool {
        self.loginInfo != nil
    }

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

    init() {}

    struct RequestOptions: OptionSet {
        let rawValue: Int

        static let login = RequestOptions(rawValue: 1 << 0)
    }

    var debug = ProcessInfo.processInfo.environment["PROFILE_REQUEST"] != nil

    private func post(endPoint: String, data: [String: Any], options: RequestOptions = []) throws -> AnyPublisher<Response, BackendAgent.ResponseError> {
        let url = (URL(string: Self.backendDomain)?.appendingPathComponent(endPoint))!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if !options.contains(.login) {
            req.setValue(self.loginInfo!.appleUserId, forHTTPHeaderField: "apple-user-id")
        }

        var debugInfo = ""
        if self.debug {
            debugInfo = debugInfo + """
            =====================request start======================
            url: \(url)
            reqeust: \(data)
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
            .tryMap { (data, _) throws -> JSON in
                if let json = try? JSON(data: data) {
                    if json["ok"].bool == true {
                        return json
                    }
                    throw ResponseError(json: json)
                }
                throw ResponseError.parseError
            }
            .mapError { (e) -> ResponseError in
                if let e = e as? ResponseError {
                    return e
                } else {
                    return ResponseError(error: e)
                }
            }
            .eraseToAnyPublisher()
    }

    func login(loginInfo: LoginInfo) throws -> AnyPublisher<Void, Never> {
        try self.post(endPoint: "/user/login",
                      data: ["appleUserId": loginInfo.appleUserId, "notificationToken": LoginManager.getNotificationToken() ?? "", "username": loginInfo.username],
                      options: .login)
            .map { _ in () }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }

    func upload(notificationToken: String) throws -> AnyPublisher<Void, Never> {
        try self.post(endPoint: "/user/update/notificationtoken", data: ["notificationToken": notificationToken])
            .map { _ in () }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }

    func upsert(endPoint: EndPointEntity) throws -> AnyPublisher<Void, ResponseError> {
        if self.loginInfo == nil {
            throw ResponseError.notLogin
        }
        return try self.post(endPoint: "/endpoint/upsert", data: ["url": endPoint.url!])
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func deleteEndPoint(by url: String) throws -> AnyPublisher<Void, ResponseError> {
        try self.post(endPoint: "/endpoint/delete", data: ["url": url])
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
