//
//  RecordItem.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/11.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation

typealias StatusCode = Int

extension StatusCode {
}

struct RecordItem {
    var duration: TimeInterval
    var statusCode: Int
    var time: Date
    var requestHeader: String
    var responseHeader: String
    var responseBody: String
}
