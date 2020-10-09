//
//  RecordDetailTextView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/14.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct RecordDetailTextView: View {
    var text: String

    var body: some View {
        ScrollView {
            Text(text).padding(20).font(.footnote)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct RecordDetailTextView_Previews: PreviewProvider {
    static var previews: some View {
        RecordDetailTextView(text: "wefwefoiwjefoiwjef")
    }
}
