//
//  JSONView.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/13.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

enum LineType {
    case healthy
    case error
    case normal

    var fontColor: Color? {
        switch self {
        case .healthy:
            return .primary
        case .error:
            return .red
        case .normal:
            return .primary
        }
    }

    var bold: Bool {
        switch self {
        case .healthy, .error:
            return true
        case .normal:
            return false
        }
    }
}

struct JSONView: View {
    var jsonData: JSON?
    var healthyPaths: [String]
    var errorPaths: [String]
    var showColors: Bool
    var rawString: String?

    init(data: Data?, healthy paths: [String] = [], error errorPaths: [String] = [], showColors: Bool = true) {
        if let data = data {
            jsonData = try? JSON(data: data)
            rawString = String(data: data, encoding: .utf8)
        } else {
            rawString = ""
        }

        healthyPaths = paths
        self.errorPaths = errorPaths
        self.showColors = showColors
    }

    private func getIndexes(for texts: [String]) -> [Range<String.Index>] {
        texts.map { jsonStr.range(of: "\"\($0)\"") }
            .filter { $0 != nil }.map { jsonStr.lineRange(for: $0!) }
    }

    var segments: [(String, LineType)] {
        let str = jsonStr
        var segs = [(String, LineType)]()
        var c = str.startIndex
        let healthyIndexes = getIndexes(for: healthyPaths).map { ($0, LineType.healthy) }
        let errorIndexes = getIndexes(for: errorPaths).map { ($0, LineType.error) }
        let indexes = (healthyIndexes + errorIndexes).sorted { $0.0.lowerBound < $1.0.lowerBound }

        for (r, type) in indexes {
            if r.lowerBound != str.startIndex && c < str.index(before: r.lowerBound) {
                segs.append((String(str[c ..< r.lowerBound]), .normal))
            }
            segs.append((String(str[r]), type))
            c = r.upperBound
        }

        if c != str.endIndex {
            segs.append((String(str[c ..< str.endIndex]), .normal))
        }
        return segs
    }

    var jsonStr: String {
        (jsonData?.rawString(options: [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]) ?? "")
    }

    var body: some View {
        ZStack {
            if jsonData != nil {
                segments.reduce(Text(""), {
                    var text = Text($1.0)

                    if $1.1.bold {
                        text = text.bold()
                    }

                    if showColors {
                        text = text.foregroundColor($1.1.fontColor)
                    }
                    return $0 + text
                })
            } else {
                Text(rawString ?? "")
            }
        }.font(Font.footnote)
    }
}

struct JSONView_Previews: PreviewProvider {
    static var previews: some View {
        let d = """
        {"a": 1, "aa": 3, "d": 4, "b": "2/wefwef"}
        """.data(using: .utf8)!
        let d2 = """
            <body></body>
        """.data(using: .utf8)!

        var v = JSONView(data: d, healthy: ["b"], error: ["a", "aa"], showColors: false)
        v.showColors = true
        return Group {
            JSONView(data: d2, healthy: ["b"], error: ["a", "aa"], showColors: false)
            v
        }
    }
}
