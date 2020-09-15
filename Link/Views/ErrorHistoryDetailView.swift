//
//  DurationHistoryDetailView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/11.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import SwiftUI

class ErrorHistoryDetailData: ObservableObject {
    @Published var url: String = ""
    @Published var items = [ScanLog]()
    var loadCancellable: AnyCancellable?

    var itemMap: [Date: [ScanLog]] {
        Dictionary(grouping: items) { item in
            item.time.startOfDay
        }
        .mapValues { $0.sorted { $0.time > $1.time } }
    }

    func load(by endPointId: String) {
//        loadCancellable = BackendAgent()
//            .listScanLogs(by: endPointId)
//            .replaceError(with: [])
//            .assign(to: \.items, on: self)
    }
}

struct ErrorHistoryDetailView: View {
    @ObservedObject var errorDetailData = ErrorHistoryDetailData()

    var endPointId: String

    init(url: String, endPointId: String) {
        self.endPointId = endPointId
        errorDetailData.url = url
    }

    var body: some View {
        List {
            ForEach(errorDetailData.itemMap.keys.sorted(), id: \.self) { date in
                Section(header: Text(date.formatDate)) {
                    ForEach(self.errorDetailData.itemMap[date]!) { item in
                        NavigationLink(destination: RecordDetailView(scanLogId: item.id)) {
                            HStack {
                                Text(item.time.formatTime)
                                Spacer()
                                Text(String(item.errorCount)).foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle(Text(errorDetailData.url.endPointPath!), displayMode: .inline)
        .onAppear {
            if !UIDevice.isPreview {
                self.errorDetailData.load(by: self.endPointId)
            }
        }
    }
}

struct ErrorHistoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let view = ErrorHistoryDetailView(url: "http://api.xinpinget.com/review/detail/56d92a5263f628d12b053be4", endPointId: "")
        view.errorDetailData.items = testScanLogs
        return NavigationView {
            view
        }
    }
}
