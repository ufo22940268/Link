//
//  JSONView.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/13.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct JSONView: View {
    var jsonData: JSON?
    var highlightPaths: [String]

    init(data: Data?, highlight paths: [String] = []) {
        if let data = data {
            jsonData = JSON(data)
        }
        highlightPaths = paths
    }

    var highlightIndexes: [Range<String.Index>] {
        highlightPaths.map { jsonStr.range(of: "\"\($0)\"") }
            .filter { $0 != nil }.map { $0! }
    }

    var segments: [(String, Bool)] {
        let str = jsonStr
        var segs = [(String, Bool)]()
        var c = str.startIndex
        for r in highlightIndexes.sorted(by: { $0.lowerBound < $1.lowerBound }) {
            if r.lowerBound != str.startIndex && c < str.index(before: r.lowerBound) {
                segs.append((String(str[c ..< str.index(before: r.lowerBound)]), false))
            }
            segs.append((String(str[r]), true))
            c = r.upperBound
        }

        if c != str.endIndex {
            segs.append((String(str[c ..< str.endIndex]), false))
        }
        return segs
    }

    var jsonStr: String {
        (jsonData?.rawString(options: [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]) ?? "")
    }

    var body: some View {
        ZStack {
            segments.reduce(Text(""), { $0 + Text($1.0).foregroundColor($1.1 ? Color.accentColor : nil) })
        }
    }
}

struct JSONView_Previews: PreviewProvider {
    static var previews: some View {
        let d = """
        {"a": 1, "b": "2/wefwef"}
        """.data(using: .utf8)!
        return JSONView(data: d, highlight: ["a", "b"])
    }
}
