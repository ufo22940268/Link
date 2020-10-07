//
//  BackendAgent+Request.swift
//  Link
//
//  Created by Frank Cheng on 2020/10/7.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import CoreData
import Foundation
import UIKit

// MARK: Utils

extension BackendAgent {
    func get(endPoint: String, query: [String: Any] = [:], options: RequestOptions = []) -> AnyPublisher<Response, ResponseError> {
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

    func post(endPoint: String, data: [String: Any] = [:], options: RequestOptions = []) -> AnyPublisher<Response, ResponseError> {
        try! post(endPoint: endPoint, data: try JSONSerialization.data(withJSONObject: data, options: []), options: options)
    }

    func post(endPoint: String, data: JSON, options: RequestOptions = []) -> AnyPublisher<Response, ResponseError> {
        try! post(endPoint: endPoint, data: try data.rawData(), options: options)
    }

    func post(endPoint: String, data: Data?, options: RequestOptions = []) throws -> AnyPublisher<Response, ResponseError> {
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
