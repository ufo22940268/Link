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

class ErrorHistoryData: ObservableObject {
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
                        ar.append((end.formatTime, Double(item.errorCount)))
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

struct ErrorHistoryView: View {
    
    @ObservedObject var errorData = ErrorHistoryData()

    var body: some View {
        List {
            ForEach(Array(errorData.chartData.keys).sorted { $0 < $1 }, id: \.self) { url in
                Section {
                    GeometryReader { proxy in
                        ZStack {
                            BarChartView(data: ChartData(values: self.errorData.chartData[url]!.0),
                                         title: url.endPointPath ?? "",
                                         legend: "",
                                         rightLegend: self.errorData.chartData[url]!.1.end.formatTime,
                                         style: Styles.barChartStyleOrangeLight,
                                         form: CGSize(width: proxy.size.width, height: 240),
                                         dropShadow: false,
                                         cornerImage: Image(systemName: "exclamationmark.triangle"),
                                         valueSpecifier: "%d")
                                .padding(0)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        NavigationLink(destination: ErrorHistoryDetailView(url: url, endPointId: self.errorData.chartData[url]!.2)) {
                            EmptyView().opacity(0)
                        }
                    }.frame(height: 240, alignment: .center)
                }
            }
         }
        .onAppear {
            self.errorData.loadData()
        }
    }
}

struct ErrorHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let view = ErrorHistoryView()
        view.errorData.items = testScanLogs
        return view
    }
}
