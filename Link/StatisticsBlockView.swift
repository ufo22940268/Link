//
//  StatisticsBlockView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/18.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

enum StatisticsBlockStatus {
    case healthy
    case error
}

struct StatisticsBlockView: View {
    var status: StatisticsBlockStatus
    var body: some View {
        Group {
            Text("Hello").padding()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(status == .healthy ? Color.green : Color.red)
        .cornerRadius(8)
    }
}

struct StatisticsBlockView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsBlockView(status: .healthy)
    }
}
