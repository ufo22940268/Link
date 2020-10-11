//
//  DurationHistoryDetailView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/11.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import SwiftUI

class MonitorHistoryDetailData: LoadableObjects<ScanLogDetail> {
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
			.subscribe(super.updateStateSubject)
	}
}

struct MonitorHistoryDetailView: View {
	// MARK: Lifecycle

	init(endPointId: String) {
		self.endPointId = endPointId
	}

	// MARK: Internal

	@StateObject var monitorDetailData = MonitorHistoryDetailData()

	var endPointId: String
	@State var showDetail: ScanLogDetail? = nil

	var body: some View {
		List {
			ForEach(monitorDetailData.itemMap.keys.sorted(by: >), id: \.self) { date in
				Section(header: Text(date.formatDate)) {
					ForEach(self.monitorDetailData.itemMap[date]!) { item in
						#if os(iOS)
						NavigationLink(destination: RecordDetailView(segment: .monitor, scanLogId: item.id)) {
							row(item: item)
						}
						#else
						Button(action: { showDetail = item }) {
							row(item: item)
								.padding()
								.contentShape(Rectangle())
						}
						.buttonStyle(PlainButtonStyle())
						#endif
					}
				}
			}
		}
		.wrapLoadable(state: monitorDetailData.loadState)
		.listStyle(GroupedListStyle())
		//        .navigationBarTitle(Text("错误数"), displayMode: .inline)
		.navigationBarTitle(Text("错误数"))
		.onAppear {
			if !MyDevice.isPreview {
				self.monitorDetailData.load(by: self.endPointId)
			}
		}
		.sheet(item: $showDetail) { detail in
			RecordDetailView(segment: .monitor, scanLogId: detail.id)
				.alertFrame()
				.alertToolbar {
					self.showDetail = nil
				}
		}
	}

	func row(item: ScanLogDetail) -> some View {
		HStack {
			Text(item.time.formatTime)
			Spacer()
			Text(String(item.errorCount)).foregroundColor(.gray)
		}
	}
}

struct MonitorHistoryDetailView_Previews: PreviewProvider {
	static var previews: some View {
		let view = MonitorHistoryDetailView(endPointId: "")
		view.monitorDetailData.items = testScanLogDetails
		return view
	}
}
