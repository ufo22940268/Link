//
//  DashboardView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/18.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI


struct DashboardView: View {
    var body: some View {
        HStack(spacing: 15) {
            StatisticsBlockView(status: .healthy(count: 8))
            StatisticsBlockView(status: .error(count: 8))
        }.padding()
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView().colorScheme(.light)
    }
}
