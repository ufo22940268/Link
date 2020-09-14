//
//  RecordDetailTextView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/14.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct RecordDetailJSONView: View {
    var text: String
    
    var json: String {
        JSON(parseJSON: text).rawString(.utf8, options: [.prettyPrinted, .withoutEscapingSlashes]) ?? ""
    }

    var body: some View {
        ZStack {
            Text(json).padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct RecordDetailJSONView_Previews: PreviewProvider {
    static var previews: some View {
        RecordDetailTextView(text: "{\"a\": 1}")
    }
}
