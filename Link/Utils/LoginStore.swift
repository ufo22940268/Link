//
//  LoginStore.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/5.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation


struct LoginInfo {
    var username: String
    var appleUserId: String
}

struct LoginStore {
    static func save(loginInfo: LoginInfo) {
        
    }
    
    static func get() -> LoginInfo {
        fatalError()
    }
}
