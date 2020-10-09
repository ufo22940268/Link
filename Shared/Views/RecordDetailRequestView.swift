//
//  RecordDetailRequestView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/12.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct RecordDetailRequestView: View {
    var item: RecordItem

    var body: some View {
        List {
            Section(header: Text("Request Header")) {
                Text(item.requestHeader).font(.footnote)
            }
        }
    }
}

struct RecordDetailRequestView_Previews: PreviewProvider {
    static var previews: some View {
        RecordDetailRequestView(item: testRecordItem)
    }
}
