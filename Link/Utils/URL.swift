//
//  URL.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/26.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import Foundation

extension String {
    var domainName: String {
        let regex = try? NSRegularExpression(pattern: "((http|https)://)?(\\w+\\.)?(?<dn>(\\w)+)\\.", options: [])
        if let match = regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: utf16.count)) {
            if let domainNameRange = Range(match.range(withName: "dn"), in: self) {
                return String(self[domainNameRange])
            }
        }
        return ""
    }

    var hostname: String {
        let regex = try? NSRegularExpression(pattern: "((http|https)://)?(?<dn>[^/]+)/?", options: [])
        if let match = regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: utf16.count)) {
            if let domainNameRange = Range(match.range(withName: "dn"), in: self) {
                return String(self[domainNameRange])
            }
        }
        return ""
    }

    func isValidURL() -> Bool {
        let urlRegEx = "^https?://.+$"
        let urlTest = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: self)
        return result
    }

    var endPointPath: String? {
        let regex = try? NSRegularExpression(pattern: "((http|https)://)?(\\w+\\.)?(?<dn>(\\w)+)\\.[^/]+(?<pa>/?.*)", options: [])
        if let match = regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: utf16.count)) {
            if let domainNameRange = Range(match.range(withName: "pa"), in: self) {
                var s = String(self[domainNameRange])
                if s.isEmpty {
                    s = "/"
                }
                return s
            }
        }
        return nil
    }
}

extension JSONDecoder {
    static var backendDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        return decoder
    }
}

extension Publisher {
    func parseArrayObjects<T>(to entity: T.Type) -> AnyPublisher<[T], Self.Failure> where Self.Output == JSON, T: Codable {
        Publishers.Map(upstream: self) { json in
            json.result.arrayValue.map { json -> T in
                try! JSONDecoder.backendDecoder.decode(entity, from: json.rawData())
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func parseObject<T>(to entity: T.Type) -> AnyPublisher<T, Self.Failure> where Self.Output == JSON, T: Codable {
        Publishers.Map(upstream: self) { json in
            try! JSONDecoder.backendDecoder.decode(entity, from: json.rawData())
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == URLSession.DataTaskPublisher.Output, Failure == URLSession.DataTaskPublisher.Failure {
    func convertToJSON() -> AnyPublisher<Response, ResponseError> {
        return tryMap { (data, _) throws -> JSON in
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
}

extension Publisher {
    func sink() -> AnyCancellable? {
        map({ _ in }).replaceError(with: ()).sink { _ in }
    }
}

extension Publisher where Output == Response, Failure == ResponseError {
    func eraseToVoidAnyPublisher() -> AnyPublisher<Void, ResponseError> {
        map{ _ in () }
            .eraseToAnyPublisher()
    }
}
