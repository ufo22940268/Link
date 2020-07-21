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

public struct Api {
    var path: String
}

struct ApiHelper {
    func fetch() -> AnyPublisher<[Api], URLError>  {
        let cancellable = URLSession.shared.dataTaskPublisher(for: URL(string: "https://api.github.com")!)
            .map { try! JSON(data: $0.data) }
            .map { self.convertToAPI(json: $0) }		
            .eraseToAnyPublisher()
        return cancellable
    }
    
    func convertToAPI(json: JSON) -> [Api] {
        return json.map { (arg0) -> Api in
            let (key, value) = arg0
            return Api(path: key)
        }
    }
}
