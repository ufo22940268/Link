//
//  Tools.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/20.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation

func extractDomainName(fromURL:  String) -> String {
    let regex = try? NSRegularExpression(pattern: "((http|https)://)?(\\w+\\.)?(?<dn>(\\w)+)\\.", options: [])
    if let match = regex?.firstMatch(in: fromURL, options: [], range: NSRange(location: 0, length: fromURL.utf16.count)) {
        if let domainNameRange = Range(match.range(withName: "dn"), in: fromURL)  {
            return String(fromURL[domainNameRange])
        }
    }
    return ""
}
