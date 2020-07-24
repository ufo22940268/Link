//
//  EndpointFetchHelper.swift
//  Link
//
//  Created by Frank Cheng on 2020/7/21.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation
import Combine
import SwiftyJSON

public struct Api: Identifiable {
    public var id: String {        
        self.paths.joined(separator: ".")
    }
    
    var paths: [String]
    var path:String {
        self.paths.joined(separator: ".")
    }
    var value: String?
}

typealias Path = [String]

struct ApiHelper {
    func fetch() -> AnyPublisher<[Api], URLError>  {
        let cancellable = URLSession.shared.dataTaskPublisher(for: URL(string: "https://api.github.com")!)
            .map { try! JSON(data: $0.data) }
            .map { self.convertToAPI(json: $0) }		
            .eraseToAnyPublisher()
        return cancellable
    }
    
    func convertToAPI(json: JSON) -> [Api] {
        let r = self.traverseJson(json: json, path: [])
        return r
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
        return [Api(paths: path, value: json.stringValue)]
    }
}
