//
//  URL.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/26.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation

extension String {

    var domainName: String {
        let regex = try? NSRegularExpression(pattern: "((http|https)://)?(\\w+\\.)?(?<dn>(\\w)+)\\.", options: [])
        if let match = regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            if let domainNameRange = Range(match.range(withName: "dn"), in: self) {
                return String(self[domainNameRange])
            }
        }
        return ""
    }
}
