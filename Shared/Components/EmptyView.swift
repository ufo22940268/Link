//
//  HistoryEmptyView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/22.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct LoadableEmptyView: View {
    var body: some View {
		LoadableTemplateView(systemImage: "tray", text: "没有记录")
    }
}

struct HistoryEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
            .preferredColorScheme(.dark)
    }
}
