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

typealias DurationSectionData = (ChartValues, DateInterval, ObjectId)

class DurationHistoryData: ObservableObject {
    @Published var items: [ScanLog]? = nil
    var loadDataCancellable: AnyCancellable?

    var chartData: [String: [String: DurationSectionData]] {
        if let items = items {
            return items.partitionByDomainName().mapValues { (dict: [String: [ScanLog]]) in
                dict.mapValues({ (items: [ScanLog]) -> DurationSectionData in
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
                })
            }
        } else {
            return [:]
        }
    }

    func loadData() {
        let timeout = Publishers.Delay(upstream: Just<[ScanLog]?>([ScanLog]()), interval: 0.5, tolerance: 0, scheduler: DispatchQueue.main)
        let load = try! BackendAgent()
            .listScanLogs()
            .map { items -> [ScanLog]? in
                items
            }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
        loadDataCancellable = Publishers.Merge(timeout, load)
            .sink { items in
                if self.items == nil || self.items!.isEmpty {
                    self.items = items
                }
            }
    }
}

typealias ChartValues = [(String, Double)]

struct DurationHistoryView: View {
    @ObservedObject var durationData = DurationHistoryData()

    func averageDuration(_ durations: [TimeInterval]) -> Double {
        let ar = durations.filter { $0 > 0 }
        return ar.reduce(0, { $0 + $1 }) / Double(ar.count)
    }

    func rowView(url: String, rowData: DurationSectionData) -> AnyView {
        AnyView(GeometryReader { proxy in
            ZStack {
                BarChartView(data: ChartData(values: rowData.0),
                             title: url.endPointPath ?? "",
                             legend: "平均 \(self.averageDuration(rowData.0.map { $0.1 }).formatDuration)",
                             style: Styles.barChartStyleNeonBlueLight,
                             form: CGSize(width: proxy.size.width, height: 240),
                             dropShadow: false,
                             cornerImage: Image(systemName: "timer"),
                             valueSpecifier: "%.0fms")
                    .padding(0)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            NavigationLink(destination: DurationHistoryDetailView(url: url, endPointId: rowData.2)) {
                EmptyView().opacity(0)
            }
        }.frame(height: 240, alignment: .center))
    }

    var body: some View {
        ZStack {
            if durationData.items != nil && durationData.items!.isEmpty {
                HistoryEmptyView()
            } else {
                List {
                    ForEach(Array(durationData.chartData.keys).sorted(), id: \.self) { (domain: String) -> AnyView in
                        let m: [String: DurationSectionData] = self.durationData.chartData[domain]!
                        let urls: [String] = Array(m.keys).sorted()
                        return AnyView(Section(header: Text(domain).font(.headline).foregroundColor(.primary)) {
                            ForEach(urls, id: \.self) { url in
                                self.rowView(url: url, rowData: m[url]!)
                            }
                        })
                    }
                }
                .id(UUID())
            }
        }
        .onAppear {
            self.durationData.loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.reloadHistory), perform: { _ in
            self.durationData.loadData()
        })
    }
}

struct DurationHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let view = DurationHistoryView()
        view.durationData.items = testScanLogs
        return view
    }
}
