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

    init(data: Data?) {
        if let data = data {
            jsonData = JSON(data)
        }
    }

    var jsonStr: String {
        (jsonData?.rawString(options: [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]) ?? "")
    }

    var body: some View {
        ZStack {
            Text(jsonStr)
        }
    }
}

struct JSONView_Previews: PreviewProvider {
    static var previews: some View {
        let d = """
        {"a": 1, "b": "2/wefwef"}
        """.data(using: .utf8)!
        return JSONView(data: d)
    }
}
