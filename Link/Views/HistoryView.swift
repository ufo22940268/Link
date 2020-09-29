//
//  HIstoryView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI
import SwiftUICharts

struct HistoryView: View {
    enum HistoryType: Int, CaseIterable {
        case duration
        case monitor
        var label: String {
            switch self {
            case .duration:
                return "时长"
            case .monitor:
                return "监控"
            }
        }
    }

    @State var type: HistoryType = .duration
    @StateObject var historyData = HistoryData()

    var pickerView: some View {
        ZStack(alignment: .center) {
            Picker("", selection: $type) {
                ForEach(HistoryType.allCases, id: \.self) { type in
                    Text(type.label).tag(type)
                }
            }
            .fixedSize()
            .pickerStyle(SegmentedPickerStyle())
        }
    }

    var contentView: some View {
        NavigationView {
            Group {
                if historyData.items != nil && historyData.items!.isEmpty {
                    HistoryEmptyView()
                } else {
                    List {
                        if type == .duration {
                            DurationHistoryView(items: historyData.items)
                        } else if type == .monitor {
                            MonitorHistoryView(items: historyData.items)
                        }
                    }
                    .listStyle(GroupedListStyle())
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    pickerView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                self.loadData()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.reloadHistory), perform: { _ in
                self.loadData()
            })
        }
    }

    private func loadData() {
        historyData.loadData()
    }

    var body: some View {
        ZStack {
            contentView
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HistoryView()
        }
    }
}
