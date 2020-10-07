//
//  DurationHistoryDetailView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/11.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import SwiftUI

class DurationHistoryDetailData: LoadableObjects<ScanLogDetail> {
    var loadCancellable: AnyCancellable?

    var itemMap: [Date: [ScanLogDetail]] {
        Dictionary(grouping: items) { item in
            item.time.startOfDay
        }
    }

    func load(by endPointId: String) {
        loadCancellable = BackendAgent()
            .getScanLogs(by: endPointId)
			.print()
			.subscribe(super.updateStateSubject)
    }
}

struct DurationHistoryDetailView: View {
    @StateObject var durationDetailData = DurationHistoryDetailData()

    var endPointId: String

    init(endPointId: String) {
        self.endPointId = endPointId
    }

    var body: some View {
        List {
            ForEach(durationDetailData.itemMap.keys.sorted(by: >), id: \.self) { date in
                Section(header: Text(date.formatDate)) {
                    ForEach(self.durationDetailData.itemMap[date]!) { item in
                        NavigationLink(destination: RecordDetailView(scanLogId: item.id)) {
                            HStack {
                                Text(item.time.formatTime)
                                Spacer()
                                Text(item.duration.formatDuration).foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
		.wrapLoadable(state: durationDetailData.loadState)
        .navigationBarTitle(Text("时长"))
        .onAppear {
            if !UIDevice.isPreview {
                self.durationDetailData.load(by: self.endPointId)
            }
        }
    }
}

struct DurationHistoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let view = DurationHistoryDetailView(endPointId: "")
        view.durationDetailData.items = testScanLogDetails
        return NavigationView {
            view
        }
    }
}
