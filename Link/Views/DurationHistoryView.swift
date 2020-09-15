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

class DurationHistoryData: ObservableObject {
    @Published var items: [ScanLog]? = nil
    var loadDataCancellable: AnyCancellable?

    var chartData: [String: (ChartValues, DateInterval, ObjectId)] {
        if let items = items {
            return Dictionary(grouping: items) { item in
                item.url
            }.mapValues { items in
                let items = items.sorted { $0.time > $1.time }
                if items.isEmpty {
                    return ([], DateInterval(), "")
                }

                var ar = [(String, Double)]()
                let maxTime = items.first!.time
                let endPointId = items.first!.endPointId

                let interval = DateInterval(start: items.last!.time, end: maxTime)
                for i in (0 ..< 10).reversed() {
                    let begin = maxTime - 60 * 5 * TimeInterval(i + 1)
                    let end = maxTime - 60 * 5 * TimeInterval(i)
                    if let item = items.first(where: { $0.time > begin && $0.time <= end }) {
                        ar.append((end.formatTime, item.duration))
                    } else {
                        ar.append((end.formatTime, 0))
                    }
                }
                return (ar, interval, endPointId)
            }
        } else {
            return [:]
        }
    }

    func loadData() {
        loadDataCancellable = try? BackendAgent()
            .listScanLogs()
            .map { items -> [ScanLog]? in
                items
            }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
    }
}

typealias ChartValues = [(String, Double)]

struct DurationHistoryView: View {
    @ObservedObject var durationData = DurationHistoryData()

    var body: some View {
        List {
            ForEach(Array(durationData.chartData.keys).sorted { $0 < $1 }, id: \.self) { url in
                Section {
                    GeometryReader { proxy in
                        ZStack {
                            BarChartView(data: ChartData(values: self.durationData.chartData[url]!.0),
                                         title: url.endPointPath ?? "",
                                         legend: "",
                                         rightLegend: self.durationData.chartData[url]!.1.end.formatTime,
                                         style: Styles.barChartStyleNeonBlueLight,
                                         form: CGSize(width: proxy.size.width, height: 240),
                                         dropShadow: false,
                                         cornerImage: Image(systemName: "timer"),
                                         valueSpecifier: "%.0fms")
                                .padding(0)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        NavigationLink(destination: DurationHistoryDetailView(url: url, endPointId: self.durationData.chartData[url]!.2)) {
                            EmptyView().opacity(0)
                        }
                    }.frame(height: 240, alignment: .center)
                }
            }
        }
        .onAppear {
            self.durationData.loadData()
        }
    }
}

struct DurationHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let view = DurationHistoryView()
        view.durationData.items = testScanLogs
        return view
    }
}
