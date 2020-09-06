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
    var loginInfo: LoginInfo {
        if let loginInfo = LoginStore.getLoginInfo() {
            return loginInfo
        } else {
            fatalError("user not logined")
        }
    }

    typealias Response = JSON

    struct ResponseError: Error {
        internal init(json: JSON? = nil) {
            self.json = json
        }

        internal init(error: Error) {
            self.error = error
        }

        var json: JSON?
        var error: Error?

        static let parseError = ResponseError()
    }

    init() {}

    struct RequestOptions: OptionSet {
        let rawValue: Int

        static let login = RequestOptions(rawValue: 1 << 0)
    }

    // TODO: Add options
    private func post(endPoint: String, data: [String: Any], options: RequestOptions = []) throws -> AnyPublisher<Response, BackendAgent.ResponseError> {
        let url = (URL(string: Self.backendDomain)?.appendingPathComponent(endPoint))!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if !options.contains(.login) {
            req.setValue(self.loginInfo.appleUserId, forHTTPHeaderField: "apple-user-id")
        }

        return URLSession.shared.dataTaskPublisher(for: req)
            .tryMap { (data, _) throws -> JSON in
                if let json = try? JSON(data: data) {
                    if json["ok"].bool == true {
                        return json
                    }
                    throw ResponseError(json: json)
                }
                throw ResponseError.parseError
            }
            .print()
            .mapError { (e) -> ResponseError in
                if let e = e as? ResponseError {
                    return e
                } else {
                    return ResponseError(error: e)
                }
            }
            .eraseToAnyPublisher()
    }

    func login(loginInfo: LoginInfo) -> AnyPublisher<Void, Never> {
        try! self.post(endPoint: "/user/login", data: ["appleUserId": "123"], options: .login)
            .map { _ in () }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }

    func upsert(endPoint: EndPointEntity) -> AnyPublisher<Void, ResponseError> {
        try! self.post(endPoint: "/endpoint/upsert", data: ["url": endPoint.url!])
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
