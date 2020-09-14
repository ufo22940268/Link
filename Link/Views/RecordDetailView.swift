//
//  RecordDetailView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/11.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

enum RecordDetailSegment: Int, RawRepresentable, CaseIterable {
    case summary = 0
    case request = 1
    case response = 2

    var label: String {
        switch self {
        case .summary:
            return "概览"
        case .request:
            return "请求"
        case .response:
            return "返回"
        }
    }
}

class RecordDetailData: ObservableObject {
    @Published var item: RecordItem?
}

let testRecordItem = RecordItem(duration: 0.3, statusCode: 200, time: Date(), requestHeader: """
CONNECT bolt.dropbox.com:443 HTTP/1.1
Host: bolt.dropbox.com
Proxy-Connection: keep-alive
""", responseHeader: """
CONNECT bolt.dropbox.com:443 HTTP/1.1
Host: bolt.dropbox.com
Proxy-Connection: keep-alive
""", responseBody: """
{
  "feeds_url": "https://api.github.com/feeds",
  "followers_url": "https://api.github.com/user/followers"
}
""")

struct RecordDetailView: View {
    @State var segment = RecordDetailSegment.summary
    @ObservedObject var recordData = RecordDetailData()

    var body: some View {
        VStack {
            Picker("", selection: $segment) {
                ForEach(RecordDetailSegment.allCases, id: \.self) { segment in
                    Text(segment.label).tag(segment.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .fixedSize()
            if recordData.item != nil {
                if segment == .summary {
                    RecordDetailSummaryView(item: recordData.item!)
                } else if segment == .request {
                    RecordDetailRequestView(item: recordData.item!)
                } else if segment == .response {
                    RecordDetailResponseView(item: recordData.item!)
                }
            }
        }
        .padding(.top)
        .listStyle(GroupedListStyle())
        .onAppear {
            self.recordData.item = testRecordItem
        }
    }
}

struct RecordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let view = RecordDetailView()
        view.recordData.item = testRecordItem
        return NavigationView {
            view.navigationBarTitle("ff", displayMode: .inline)
        }.colorScheme(.dark)
    }
}
