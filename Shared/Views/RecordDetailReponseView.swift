//
//  RecordDetailReponseView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/12.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct RecordDetailResponseView: View {
    var item: RecordItem


    var body: some View {
        List {
            Section(header: Text("Response Header")) {
                Text(item.responseHeader)
                    .header()
            }

            Section(header: Text("Body")) {
                Button("预览JSON") {
                    self.showText = true
                }
                Text("预览JSON")
                Text("预览文本")
            }
        }
    }
}

struct RecordDetailReponseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecordDetailResponseView(item: testRecordItem)
                .listStyle(GroupedListStyle())
        }
        .navigationBarHidden(true)
    }
}
