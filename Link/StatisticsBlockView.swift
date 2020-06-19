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
        VStack {
            HStack {
                Image(systemName: "pencil.circle.fill")
                Spacer()
            }
            HStack {
                Spacer()
                Text("asdfasdf")
            }
        }
        .padding()
        .background(status == .healthy ? Color.green : Color.red)
        .cornerRadius(8)
    }
}

struct StatisticsBlockView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsBlockView(status: .healthy).colorScheme(.dark)
    }
}
