//
//  DurationHistoryDetailView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/11.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import SwiftUI

private let testItems = [DurationHistoryDetailItem(time: Date(), duration: 30), DurationHistoryDetailItem(time: Date(), duration: 20)]

class DurationHistoryDetailData: ObservableObject {
    @Published var url: String = ""
    @Published var items = [DurationHistoryDetailItem]()
    var itemMap: [Date: [DurationHistoryDetailItem]] {
        Dictionary(grouping: items) { item in
            item.time.startOfDay
        }
    }
}

struct DurationHistoryDetailView: View {
    @ObservedObject var durationDetailData = DurationHistoryDetailData()

    init(url: String) {
        durationDetailData.url = url
        durationDetailData.items = testItems
    }

    var body: some View {
        List {
            ForEach(durationDetailData.itemMap.keys.sorted(), id: \.self) { date in
                Section(header: Text(date.formatDate)) {
                    ForEach(self.durationDetailData.itemMap[date]!) { item in
                        NavigationLink(destination: EmptyView()) {
                            HStack {
                                Text(item.time.formatTime)
                                Spacer()
                                Text((item.duration / 1000).formatDuration).foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle(Text(durationDetailData.url.endPointPath!), displayMode: .inline)
    }
}

struct DurationHistoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let view = DurationHistoryDetailView(url: "http://api.xinpinget.com/review/detail/56d92a5263f628d12b053be4")
        view.durationDetailData.items = testItems
        return NavigationView {
            view
        }
    }
}
