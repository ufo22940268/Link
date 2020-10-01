//
//  HIstoryView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI
import SwiftUICharts

enum TimeSpan: TimeInterval, RawRepresentable, CaseIterable, Identifiable {
    case fiveMin = 3000
    case tenMin = 6000
    case fiftenMin = 9000

    var id: Self {
        self
    }

    var label: String {
        "\(Int(rawValue / 60))分钟"
    }
}

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
    @State var timeSpan = TimeSpan.fiveMin

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

    var timeSpanPickerView: some View {
        Picker(timeSpan.label, selection: $timeSpan) {
            ForEach(TimeSpan.allCases) { ts in
                Text(ts.label).tag(ts)
            }
        }
        .pickerStyle(MenuPickerStyle())
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

                ToolbarItem(placement: .primaryAction) {
                    timeSpanPickerView
                }
            }
            .onAppear {
                self.loadData()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
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
