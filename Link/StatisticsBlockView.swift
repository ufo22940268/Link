//
//  StatisticsBlockView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/18.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct StatisticsBlockView: View {
    var i: Int
    var body: some View {
        Group {
            Text("Hello \(i)").padding()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color.red)
        .cornerRadius(8)
    }
}

struct StatisticsBlockView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsBlockView(i: 3)
    }
}
