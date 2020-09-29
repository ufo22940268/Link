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
    case monitor = 1
    case response = 2

    var label: String {
        switch self {
        case .summary:
            return "概览"
        case .monitor:
            return "监控"
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
    @State var sheetType: SheetType? = nil

    var pickerView: some View {
        ZStack {
            Picker("", selection: $segment) {
                ForEach(RecordDetailSegment.allCases, id: \.self) { segment in
                    Text(segment.label).tag(segment.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .fixedSize()
            .frame(alignment: .center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top)
    }

    var body: some View {
        List {
            pickerView.asListHeader()
            if recordData.item != nil {
                if segment == .summary {
                    RecordDetailSummaryView(item: recordData.item!)
                } else if segment == .monitor {
                    RecordDetailMonitorView(item: recordData.item!)
                } else if segment == .response {
                    RecordDetailResponseView(item: recordData.item!, sheetType: $sheetType)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .sheet(item: $sheetType, onDismiss: {
            self.sheetType = nil
        }) { st -> AnyView in
            var content: AnyView
            let item = self.recordData.item!
            switch st {
            case .text:
                content = AnyView(RecordDetailTextView(text: item.responseBody))
            case .json:
                content = AnyView(RecordDetailJSONView(text: item.responseBody))
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
        .onAppear {
            if !UIDevice.isPreview {
                self.recordData.load(id: self.scanLogId)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RecordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let view = RecordDetailView(scanLogId: testScanLogId)
        view.recordData.item = testRecordItem
        view.segment = .response
        return NavigationView {
            view.navigationBarTitle("ff", displayMode: .inline)
        }.colorScheme(.dark)
    }
}
