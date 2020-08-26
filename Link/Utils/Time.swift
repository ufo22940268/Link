//
//  Time.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/26.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation

extension TimeInterval {
    var formatDuration: String {
        "\(Int(floor(self * 1000)))ms"
    }
}
