//
//  DurationHistoryDetailItem.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/11.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation

struct ScanLogDetail: Identifiable, Codable {
    var id: String
    var time: Date
    var duration: TimeInterval
    var errorCount: Int
}
