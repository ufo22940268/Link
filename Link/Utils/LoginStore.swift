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

let USERNAME_KEY = "username"
let APPLE_USER_ID_KEY = "apple_user_id"

struct LoginStore {    
    
    static func save(loginInfo: LoginInfo) {
        UserDefaults.standard.set(loginInfo.username, forKey: USERNAME_KEY)
        UserDefaults.standard.set(loginInfo.appleUserId, forKey: APPLE_USER_ID_KEY)
    }

    static func getLoginInfo() -> LoginInfo? {
        if let userId = UserDefaults.standard.string(forKey: APPLE_USER_ID_KEY) {
            let userName = UserDefaults.standard.string(forKey: USERNAME_KEY)
            return LoginInfo(username: userName ?? "", appleUserId: userId)
        } else {
            return nil
        }
    }
}
