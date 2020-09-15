//
//  DurationHistoryIOtem.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/10.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation

struct ErrorHistoryItem: Identifiable {
    var id: ObjectId
    var url: String
    var time: Date
    var errorCount: Int
    var endPointId: ObjectId
}
