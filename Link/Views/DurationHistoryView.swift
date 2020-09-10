//
//  DurationHistoryView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/10.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import SwiftUI
import SwiftUICharts

let testHistoryItems: [DurationHistoryItem] = (0 ..< 10).reversed().map { i in
    let t = DurationHistoryItem(url: "/a/b", time: Date() - 5 * 60 * TimeInterval(i), duration: TimeInterval((0 ..< 100).randomElement()!))
    return t
}

class DurationHistoryData: ObservableObject {
    @Published var items: [DurationHistoryItem]? = nil
    var loadDataCancellable: AnyCancellable?

    var chartData: [String: ChartValues] {
        if let items = items {
            return Dictionary(grouping: items) { item in
                item.url
            }.mapValues { items in
                items.map { item in
                    (item.formatTime, item.duration)
                }
            }
        } else {
            return [:]
        }
    }

    func loadData() {
        loadDataCancellable = try? BackendAgent()
            .listScanLogs()
            .map { items -> [DurationHistoryItem]? in
                items
            }
            .replaceError(with: nil)
            .print()
            .subscribe(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
    }
}

typealias ChartValues = [(String, Double)]

struct DurationHistoryView: View {
    @ObservedObject var durationData: DurationHistoryData = DurationHistoryData()

    var body: some View {
        List {
            ForEach(Array(durationData.chartData.keys), id: \.self) { key in
                Section {
                    GeometryReader { proxy in
                        ZStack {
                            BarChartView(data: ChartData(values: self.durationData.chartData[key]!),
                                         title: key.endPointPath ?? "",
                                         legend: "每5分钟",
                                         form: CGSize(width: proxy.size.width, height: 240), dropShadow: false, valueSpecifier: "%.0fms")
                                .padding(0)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }.frame(height: 240, alignment: .center)
                }
            }
        }
        .onAppear {
//            self.durationData.items = testHistoryItems
            self.durationData.loadData()
        }
    }
}

struct DurationHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        return DurationHistoryView()
    }
}
