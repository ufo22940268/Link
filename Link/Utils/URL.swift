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
        if let match = regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: utf16.count)) {
            if let domainNameRange = Range(match.range(withName: "dn"), in: self) {
                return String(self[domainNameRange])
            }
        }
        return ""
    }

    var hostname: String {
        let regex = try? NSRegularExpression(pattern: "((http|https)://)?(?<dn>[^/]+)/?", options: [])
        if let match = regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: utf16.count)) {
            if let domainNameRange = Range(match.range(withName: "dn"), in: self) {
                return String(self[domainNameRange])
            }
        }
        return ""
    }

    func isValidURL() -> Bool {
        let urlRegEx = "^https?://.+$"
        let urlTest = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: self)
        return result
    }

    var endPointPath: String? {
        let regex = try? NSRegularExpression(pattern: "((http|https)://)?(\\w+\\.)?(?<dn>(\\w)+)\\.[^/]+(?<pa>/?.*)", options: [])
        if let match = regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            if let domainNameRange = Range(match.range(withName: "pa"), in: self) {
                var s = String(self[domainNameRange])
                if s.isEmpty {
                    s = "/"
                }
                return s
            }
        }
        return nil
    }
}
