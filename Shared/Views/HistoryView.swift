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
    case fiveMin = 300
    case tenMin = 600
    case fiftenMin = 900
    case oneHour = 3600

    var id: Self {
        self
    }

    var label: String {
        if rawValue < 3600 {
            return "\(Int(rawValue / 60))分钟"
        } else {
            return "\(Int(rawValue / 3600))小时"
        }
    }

    static let `default` = Self.fiveMin

    static func parse(_ v: TimeInterval) -> Self {
        allCases.first { $0.rawValue == v } ?? .default
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
		Picker(historyData.timeSpan.label, selection: $historyData.timeSpan) {
            ForEach(TimeSpan.allCases) { ts in
                Text(ts.label).tag(ts)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }

    var contentView: some View {
        NavigationView {
            LoadableView(loadableState: historyData.loadState) {
                List {
                    if type == .duration {
                        DurationHistoryView(items: historyData.items, timeSpan: historyData.timeSpan)
                    } else if type == .monitor {
                        MonitorHistoryView(items: historyData.items, timeSpan: historyData.timeSpan)
                    }
                }
                .listStyle(GroupedListStyle())
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
			// TODO
//            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
//                self.loadData()
//            }
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
