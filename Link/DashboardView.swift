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
        HStack {
            StatisticsBlockView(status: .healthy)
            StatisticsBlockView(status: .error)
        }.padding()
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
