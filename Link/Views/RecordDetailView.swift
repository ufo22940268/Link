//
//  RecordDetailView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/11.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
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
    var loadCancellable: AnyCancellable?

    func load(id: String) {
        loadCancellable = BackendAgent().getScanLog(id: id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }) { item in
                self.item = item
            }
    }
}

struct RecordDetailView: View {
    @State var segment = RecordDetailSegment.summary
    @ObservedObject var recordData = RecordDetailData()
    var scanLogId: String

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
            self.recordData.load(id: self.scanLogId)
        }
    }
}

struct RecordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let view = RecordDetailView(scanLogId: testScanLogId)
        view.recordData.item = testRecordItem
        return NavigationView {
            view.navigationBarTitle("ff", displayMode: .inline)
        }.colorScheme(.dark)
    }
}