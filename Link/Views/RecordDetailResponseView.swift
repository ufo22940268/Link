//
//  RecordDetailReponseView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/12.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI
enum SheetType: Int, Identifiable, CaseIterable {
    var id: Int {
        return rawValue
    }

    case text
    case json

    var title: String {
        switch self {
        case .text:
            return "文本"
        case .json:
            return "JSON"
        }
    }
}


struct RecordDetailResponseView: View {
    var item: RecordItem
    @Binding var sheetType: SheetType?


    var body: some View {
        Group {
            Section(header: Text("Response Header")) {
                Text(item.responseHeader)
                    .header()
                    .fixedSize()
            }

            Section(header: Text("Body")) {
                ForEach(SheetType.allCases, id: \.self, content: { st in
                    Button("预览\(st.title)") {
                        self.sheetType = st
                    }
                })
            }
        }
    }
}

struct RecordDetailReponseView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            RecordDetailResponseView(item: testRecordItem, sheetType: Binding.constant(SheetType.text))
        }
    }
}
