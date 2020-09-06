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
    var loginInfo: LoginInfo

    init() {
        if let loginInfo = LoginStore.getLoginInfo() {
            self.loginInfo = loginInfo
        } else {
            fatalError("user not logined")
        }
    }

    private func post(endPoint: String, data: [String: Any]) throws -> AnyPublisher<Void, Never> {
        let url = (URL(string: Self.backendDomain)?.appendingPathComponent(endPoint))!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return URLSession.shared.dataTaskPublisher(for: req)
            .map { _ in
                ()
            }
            .catch { _ in
                Empty()
            }
            .eraseToAnyPublisher()
    }

    func login(loginInfo: LoginInfo) -> AnyPublisher<Void, Never> {
        try! self.post(endPoint: "/user/login", data: ["appleUserId": "123"])
    }
}
