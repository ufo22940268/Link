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
    enum HistoryType: Int, CaseIterable {
        case duration
        case error
        var label: String {
            switch self {
            case .duration:
                return "返回时间"
            case .error:
                return "错误"
            }
        }
    }

    @State var type: HistoryType = .duration

    var contentView: some View {
        NavigationView {
            VStack {
                Picker("", selection: $type) {
                    ForEach(HistoryType.allCases, id: \.self) { type in
                        Text(type.label).tag(type)
                    }
                }
                .fixedSize()
                .pickerStyle(SegmentedPickerStyle())
                .environment(\.horizontalSizeClass, .compact)
                if type == .duration {
                    DurationHistoryView()
                } else if type == .error {
                    ErrorHistoryView()
                }
            }
            .navigationBarHidden(true)
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle("", displayMode: .inline)
        }
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
