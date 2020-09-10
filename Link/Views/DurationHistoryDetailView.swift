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
    var items = [DurationHistoryDetailItem]()
}

struct DurationHistoryDetailView: View {
    @ObservedObject var durationDetailData = DurationHistoryDetailData()

    init(url: String) {
        durationDetailData.url = url
    }

    var body: some View {
        List {
            ForEach(durationDetailData.items) { item in
                NavigationLink(destination: EmptyView()) {
                    HStack {
                        Text(item.time.formatTime)
                        Spacer()
                        Text((item.duration / 1000).formatDuration).foregroundColor(.gray)
                    }
                }
            }
        }
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
