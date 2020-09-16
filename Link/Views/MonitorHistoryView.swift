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

typealias ErrorSectionData = (ChartValues, DateInterval, ObjectId)

class MonitorHistoryData: ObservableObject {
    @Published var items: [ScanLog]? = nil
    var loadDataCancellable: AnyCancellable?

    var chartData: [String: [String: ErrorSectionData]] {
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
                            ar.append((end.formatTime, Double(item.errorCount)))
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

struct MonitorHistoryView: View {
    @ObservedObject var errorData = MonitorHistoryData()

    func totalErrorCount(_ data: ChartValues) -> Int {
        data.reduce(0, { $0 + Int($1.1) })
    }

    func rowView(url: String, data: ErrorSectionData) -> some View {
        GeometryReader { proxy in
            ZStack {
                BarChartView(data: ChartData(values: data.0),
                             title: url.endPointPath ?? "",
                             legend: self.totalErrorCount(data.0) > 0 ? "\(String(self.totalErrorCount(data.0))) 个报警" : "",
                             style: Styles.barChartStyleOrangeLight,
                             form: CGSize(width: proxy.size.width, height: 240),
                             dropShadow: false,
                             cornerImage: Image(systemName: "exclamationmark.triangle"),
                             valueSpecifier: "%d")
                    .padding(0)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            NavigationLink(destination: ErrorHistoryDetailView(url: url, endPointId: data.2)) {
                EmptyView().opacity(0)
            }
        }.frame(height: 240, alignment: .center)
    }

    var body: some View {
        List {
            ForEach(Array(errorData.chartData.keys).sorted { $0 < $1 }, id: \.self) { domain -> AnyView in
                let m: [String: ErrorSectionData] = self.errorData.chartData[domain]!
                return AnyView(
                    Section(header: Text(domain).font(.headline).foregroundColor(.primary)) {
                        ForEach(Array(m.keys).sorted(), id: \.self) { url in
                            self.rowView(url: url, data: m[url]!)
                        }
                    }
                )
            }
        }
        .onAppear {
            self.errorData.loadData()
        }
    }
}

struct ErrorHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let view = MonitorHistoryView()
        view.errorData.items = testScanLogs
        return view
    }
}
