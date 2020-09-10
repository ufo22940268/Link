//
//  DurationHistoryIOtem.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/10.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation

struct DurationHistoryItem {
    var url: String
    var time: Date
    var duration: TimeInterval
    
    var formatTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: time)
    }
}