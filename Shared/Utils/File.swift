//
//  File.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/26.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation

extension Data {
    var isValidJSON: Bool {
        (try? JSON(data: self)) != nil
    }
}
