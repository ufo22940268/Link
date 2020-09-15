//
//  DurationHistoryDetailView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/11.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import SwiftUI

class DurationHistoryDetailData: ObservableObject {
    @Published var url: String = ""
    @Published var items = [ScanLogDetail]()
    var loadCancellable: AnyCancellable? = nil
    
    var itemMap: [Date: [ScanLogDetail]] {
        Dictionary(grouping: items) { item in
            item.time.startOfDay
        }
    }

    func load(by endPointId: String) {
        loadCancellable = BackendAgent()
            .listScanLogs(by: endPointId)
            .replaceError(with: [])
            .assign(to: \.items, on: self)
    }
}

struct DurationHistoryDetailView: View {
    @ObservedObject var durationDetailData = DurationHistoryDetailData()

    var endPointId: String

    init(url: String, endPointId: String) {
        self.endPointId = endPointId
        durationDetailData.url = url
    }

    var body: some View {
        List {
            ForEach(durationDetailData.itemMap.keys.sorted(), id: \.self) { date in
                Section(header: Text(date.formatDate)) {
                    ForEach(self.durationDetailData.itemMap[date]!) { item in
                        NavigationLink(destination: RecordDetailView(scanLogId: item.id)) {
                            HStack {
                                Text(item.time.formatTime)
                                Spacer()
                                Text((item.duration / 1000).formatDuration).foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle(Text(durationDetailData.url.endPointPath!), displayMode: .inline)
        .onAppear {
            if !UIDevice.isPreview {
                self.durationDetailData.load(by: self.endPointId)
            }
        }
    }
}

struct DurationHistoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let view = DurationHistoryDetailView(url: "http://api.xinpinget.com/review/detail/56d92a5263f628d12b053be4", endPointId: "")
        view.durationDetailData.items = testScanLogDetails
        return NavigationView {
            view
        }
    }
}
