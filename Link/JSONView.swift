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
            return .accentColor
        case .error:
            return .red
        case .normal:
            return nil
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

    init(data: Data?, healthy paths: [String] = [], error errorPaths: [String] = []) {
        if let data = data {
            jsonData = JSON(data)
        }
        healthyPaths = paths
        self.errorPaths = errorPaths
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
            segments.reduce(Text(""), {
                var text = Text($1.0)
                    .foregroundColor($1.1.fontColor)
                    .font(Font.footnote)
                if $1.1.bold {
                    text = text.bold()
                }
                return $0 + text
            })
        }
    }
}

struct JSONView_Previews: PreviewProvider {
    static var previews: some View {
        let d = """
        {"a": 1, "aa": 3, "d": 4, "b": "2/wefwef"}
        """.data(using: .utf8)!
        return JSONView(data: d, healthy: ["b"], error: ["a", "aa"])
    }
}
