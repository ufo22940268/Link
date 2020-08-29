//
//  ApiDetailData.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/29.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine

class ApiDetailData: ObservableObject {
    
    @Published var watchValue: String?
    @Published var watch: Bool
    
    init(api: ApiEntity) {
        watchValue = api.watchValue
        watch = api.watch
    }
}
