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
    @State var sheetType: SheetType? = nil

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

    var headerAndSheet: some View {
        Text("Body").sheet(item: $sheetType, onDismiss: {
            self.sheetType = nil
        }) { st -> AnyView in
            var content: AnyView
            switch st {
            case .text:
                content = AnyView(RecordDetailTextView(text: self.item.responseBody))
            case .json:
                content = AnyView(RecordDetailJSONView(text: self.item.responseBody))
            }
            return AnyView(
                NavigationView {
                    content
                        .navigationBarItems(trailing: Button("完成") {
                            self.sheetType = nil
                        })
                        .navigationBarTitle(Text(st.title), displayMode: .inline)
                }
            )
        }
    }

    var body: some View {
        Group {
            Section(header: Text("Response Header")) {
                Text(item.responseHeader)
                    .header()
                    .fixedSize()
            }

            Section(header: headerAndSheet) {
                ForEach(SheetType.allCases, id: \.self, content: { st in
                    Button("预览\(st.title)") {
                        self.sheetType = st
                    }
                })
            }
            EmptyView()
        }
    }
}

struct RecordDetailReponseView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            RecordDetailResponseView(item: testRecordItem)
        }
    }
}
