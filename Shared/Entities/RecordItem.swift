//
//  RecordItem.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/11.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation

typealias StatusCode = Int

struct RecordItem: Decodable {
    var duration: TimeInterval
    var statusCode: Int
    var time: Date
    var requestHeader: String
    var responseHeader: String
    var responseBody: String
    var fields: [WatchField]

    struct WatchField: Decodable, Identifiable {
        var id: String {
            path
        }
        var path: String
        var value: String
        var watchValue: String

        var match: Bool {
            return value == watchValue
        }
    }

    var okFields: [WatchField] {
        fields.filter { $0.match }
    }

    var failedFields: [WatchField] {
        fields.filter { !$0.match }
    }
}
