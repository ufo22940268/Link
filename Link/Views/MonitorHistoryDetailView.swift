//
//  DurationHistoryDetailView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/11.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import SwiftUI

class MonitorHistoryDetailData: ObservableObject {
    @Published var items = [ScanLogDetail]()
    var loadCancellable: AnyCancellable?

    var itemMap: [Date: [ScanLogDetail]] {
        Dictionary(grouping: items) { item in
            item.time.startOfDay
        }
        .mapValues { $0.sorted { $0.time > $1.time } }
    }

    func load(by endPointId: String) {
        loadCancellable = BackendAgent()
            .getScanLogs(by: endPointId)
            .replaceError(with: [])
            .assign(to: \.items, on: self)
    }
}

struct MonitorHistoryDetailView: View {
    @StateObject var errorDetailData = MonitorHistoryDetailData()

    var endPointId: String

    init(endPointId: String) {
        self.endPointId = endPointId
    }

    var body: some View {
        List {
            ForEach(errorDetailData.itemMap.keys.sorted(by: >), id: \.self) { date in
                Section(header: Text(date.formatDate)) {
                    ForEach(self.errorDetailData.itemMap[date]!) { item in
                        NavigationLink(destination: RecordDetailView(segment: .monitor, scanLogId: item.id)) {
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
        .navigationBarTitle(Text("错误数"), displayMode: .inline)
        .onAppear {
            if !UIDevice.isPreview {
                self.errorDetailData.load(by: self.endPointId)
            }
        }
    }
}

struct ErrorHistoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let view = MonitorHistoryDetailView(endPointId: "")
        view.errorDetailData.items = testScanLogDetails
        return NavigationView {
            view
        }
    }
}
