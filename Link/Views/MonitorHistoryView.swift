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

typealias MonitorSectionData = (ChartValues, ObjectId)

class MonitorHistoryData: HistoryData {
    /// DomainName: [TimeSpan: SectionData]
    var chartData: [String: [String: MonitorSectionData]] {
        if let items = items {
            return items.partitionByDomainName().mapValues { (dict: [String: [ScanLog]]) in
                dict.mapValues({ (items: [ScanLog]) -> MonitorSectionData in
                    let items = items.sorted { $0.time > $1.time }
                    if items.isEmpty {
                        return ([], "")
                    }

                    var ar = [(String, Double)]()
                    let maxTime = Date()
                    let endPointId = items.first!.endPointId

                    for i in (0 ..< 10).reversed() {
                        let begin = maxTime - 60 * 5 * TimeInterval(i + 1)
                        let end = maxTime - 60 * 5 * TimeInterval(i)
                        if let item = items.first(where: { $0.time > begin && $0.time <= end }) {
                            ar.append((end.formatTime, Double(item.errorCount)))
                        } else {
                            ar.append((end.formatTime, 0))
                        }
                    }
                    return (ar, endPointId)
                })
            }
        } else {
            return [:]
        }
    }
}

struct MonitorHistoryView: View {
    @ObservedObject var monitorData = MonitorHistoryData()

    func totalErrorCount(_ data: ChartValues) -> Int {
        data.reduce(0, { $0 + Int($1.1) })
    }

    func rowView(url: String, data: MonitorSectionData) -> some View {
        return GeometryReader { proxy in
            ZStack {
                BarChartView(data: ChartData(values: data.0),
                             title: url.endPointPath ?? "",
                             legend: self.totalErrorCount(data.0) > 0 ? "\(String(self.totalErrorCount(data.0))) 个报警" : "10分钟内没有发现报警",
                             style: Styles.barChartStyleOrangeLight,
                             form: CGSize(width: proxy.size.width, height: 240),
                             dropShadow: false,
                             cornerImage: Image(systemName: "exclamationmark.triangle"),
                             valueSpecifier: "%d")
                    .padding(0)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            NavigationLink(destination: MonitorHistoryDetailView(url: url, endPointId: data.1)) {
                EmptyView().opacity(0)
            }
        }.frame(height: 240, alignment: .center)
    }

    var body: some View {
        ZStack {
            if monitorData.items != nil && monitorData.items!.isEmpty {
                HistoryEmptyView()
            } else {
                List {
                    ForEach(Array(monitorData.chartData.keys).sorted(by: >), id: \.self) { domain -> AnyView in
                        let m: [String: MonitorSectionData] = self.monitorData.chartData[domain]!
                        return AnyView(
                            Section(header: Text(domain).font(.headline).foregroundColor(.primary)) {
                                ForEach(Array(m.keys).sorted(), id: \.self) { url in
                                    self.rowView(url: url, data: m[url]!)
                                }
                            }
                        )
                    }
                }
                .id(UUID())
            }
        }
        .onAppear {
            self.monitorData.loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.reloadHistory), perform: { _ in
            print("------------reload monitor history------------")
            self.monitorData.loadData()
        })
    }
}

struct ErrorHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let view = MonitorHistoryView()
        view.monitorData.items = testScanLogs
        return view
    }
}
