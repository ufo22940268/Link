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

class MonitorHistoryData: ObservableObject {
    @Published var items: [ScanLog]? = nil

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
//                    let maxTime = Date()
                    let maxTime = items.first!.time
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
    var items: [ScanLog]?
    var timeSpan: TimeSpan

    init(items: [ScanLog]?, timeSpan: TimeSpan) {
        self.items = items
        self.timeSpan = timeSpan
    }

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
                        let begin = maxTime - timeSpan.rawValue * TimeInterval(i + 1)
                        let end = maxTime - timeSpan.rawValue * TimeInterval(i)
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
            NavigationLink(destination: MonitorHistoryDetailView(endPointId: data.1)) {
                EmptyView().opacity(0)
            }
        }.frame(height: 240, alignment: .center)
    }

    var body: some View {
        Group {
            if items != nil && items!.isEmpty {
                HistoryEmptyView()
            } else {
                ForEach(Array(chartData.keys).sorted(by: >), id: \.self) { domain -> AnyView in
                    let m: [String: MonitorSectionData] = self.chartData[domain]!
                    return AnyView(
                        Section(header: Text(domain).font(.headline).foregroundColor(.primary).textCase(.lowercase)) {
                            ForEach(Array(m.keys).sorted(), id: \.self) { url in
                                self.rowView(url: url, data: m[url]!)
                            }
                        }
                    )
                }
            }
        }
    }
}

struct ErrorHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
//        let view = MonitorHistoryView()
//        view.monitorData.items = testScanLogs
//        return view
    }
}
