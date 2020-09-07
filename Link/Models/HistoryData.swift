//
//  HistoryDAta.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/5.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

class HistoryData: ObservableObject {
    @Published var loginInfo: LoginInfo?

    var cancellable: AnyCancellable?

    var hasLogined: Bool {
        loginInfo != nil
    }

    init() {
        loginInfo = LoginManager.getLoginInfo()
        cancellable = $loginInfo
            .filter { $0 != nil }
            .flatMap { info in
                try! BackendAgent().login(loginInfo: info!)
            }
            .sink(receiveValue: { () in

            })
    }
}
