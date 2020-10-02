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

extension Array where Self.Element == ScanLog {
    func partitionByDomainName() -> [String: [String: [ScanLog]]] {
        Dictionary(grouping: self) { t in
            t.url.domainName
        }
        .mapValues({ ar in
            Dictionary(grouping: ar) { t in
                t.url
            }
        })
    }
}

typealias DurationSectionData = (ChartValues, ObjectId)

typealias ChartValues = [(String, Double)]

struct DurationHistoryView: View {
    var items: [ScanLog]?
    var timeSpan: TimeSpan

    init(items: [ScanLog]?, timeSpan: TimeSpan) {
        self.items = items
        self.timeSpan = timeSpan
    }

    var chartData: [String: [String: DurationSectionData]] {
        if let items = items {
            return items.partitionByDomainName().mapValues { (dict: [String: [ScanLog]]) in
                dict.mapValues({ (items: [ScanLog]) -> DurationSectionData in
                    let items = items.sorted { $0.time > $1.time }
                    if items.isEmpty {
                        return ([], "")
                    }

                    var ar = [(String, Double)]()
//                    let maxTime = Date()
                    let maxTime = items.first!.time
                    let endPointId = items.first!.endPointId
                    for i in (0 ..< 10).reversed() {
                        let begin = maxTime - timeSpan.rawValue * TimeInterval(i + 1)
                        let end = maxTime - timeSpan.rawValue * TimeInterval(i)
                        if let item = items.first(where: { $0.time > begin && $0.time <= end }) {
                            ar.append((end.formatTime, item.duration))
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

    func averageDuration(_ data: ChartValues) -> String {
        let ar = data.map { $0.1 }.filter { $0 > 0 }
        if ar.isEmpty {
            return "0 ms"
        }

        return (ar.reduce(0, { $0 + $1 }) / Double(ar.count)).formatDuration
    }

    func rowView(url: String, rowData: DurationSectionData) -> AnyView {
        AnyView(GeometryReader { proxy in
            ZStack {
                BarChartView(data: ChartData(values: rowData.0),
                             title: url.endPointPath ?? "",
                             legend: "平均 \(self.averageDuration(rowData.0))",
                             style: Styles.barChartStyleNeonBlueLight,
                             form: CGSize(width: proxy.size.width, height: 240),
                             dropShadow: false,
                             cornerImage: Image(systemName: "timer"),
                             valueSpecifier: "%.0fms")
                    .padding(0)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            NavigationLink(destination: DurationHistoryDetailView(endPointId: rowData.1)) {
                EmptyView().opacity(0)
            }
        }.frame(height: 240, alignment: .center))
    }

    var body: some View {
        Group {
            if items != nil && items!.isEmpty {
                HistoryEmptyView()
            } else {
                ForEach(Array(chartData.keys).sorted(), id: \.self) { (domain: String) -> AnyView in
                    let m: [String: DurationSectionData] = self.chartData[domain]!
                    let urls: [String] = Array(m.keys).sorted()
                    return AnyView(Section(header: Text(domain).font(.headline).foregroundColor(.primary).textCase(.lowercase)) {
                        ForEach(urls, id: \.self) { url in
                            self.rowView(url: url, rowData: m[url]!)
                        }
                    })
                }
            }
        }
    }
}

struct DurationHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        DurationHistoryView(items: testScanLogs, timeSpan: .fiveMin)
    }
}
