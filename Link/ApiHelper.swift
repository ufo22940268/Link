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
        self.path
    }
    
    var paths: [String] {
        self.path.split(separator: ".").map { String($0) }
    }
    var path: String
    var value: String?
    var watch: Bool = false
}

extension Api: Hashable {
    
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
        var r = self.traverseJson(json: json, path: [])
        r.sort { l, r in l.path > r.path }
        return r
    }
    
    private func traverseJson(json: JSON, path: Path) -> [Api] {
        var j: JSON = json
        if let ar = json.array, ar.count > 0 {
            j = ar[0]
        }

        if let dict = j.dictionary {
            let ar = dict.map { args in
                self.traverseJson(json: args.value, path:  path + [args.key])
            }.flatMap { $0 }
            return ar
        }
        return [Api(path: path.joined(separator: "."), value: json.stringValue)]
    }
}
