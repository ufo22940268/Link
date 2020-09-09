//
//  HIstoryView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI
import SwiftUICharts

struct HistoryView: View {
    var contentView: some View {
        List {
            ForEach(0 ..< 2) { _ in
                Section {
                    GeometryReader { proxy in
                        ZStack {
                            BarChartView(data: ChartData(values: [("2018 Q4", 63150), ("2019 Q1", 50900), ("2019 Q2", 77550), ("2019 Q3", 79600), ("2019 Q4", 92550), ("2019 Q4", 92550), ("2019 Q4", 92550), ("2019 Q4", 92550), ("2019 Q4", 92550), ("2019 Q4", 92550), ("2019 Q4", 92550), ("2019 Q4", 92550)]), title: "asdf", legend: "Quarterly", form: CGSize(width: proxy.size.width, height: 240), dropShadow: false).padding(0)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }.frame(height: 240, alignment: .center)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
    }

    var body: some View {
        ZStack {
            contentView
        }
    }
}

struct HIstoryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HistoryView()
            HistoryView().colorScheme(.dark)
        }
    }
}
