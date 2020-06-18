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
            StatisticsBlockView(i: 2)
            StatisticsBlockView(i: 5)
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
