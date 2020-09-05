//
//  HIstoryView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var data: HistoryData = HistoryData()

    var emptyView: some View {
        HistoryEmptyView(data: data)
    }

    var contentView: some View {
        Text("logined")
    }

    var body: some View {
        ZStack {
            if data.hasLogined {
                contentView
            } else {
                emptyView
            }
        }
    }
}

struct HIstoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
