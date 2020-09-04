//
//  HistoryEmptyView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct HistoryEmptyView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("请先登录开启服务器端监控").font(.callout)
            AppleIDLoginButton().frame(height: 45)
        }.padding(25)
    }
}

struct HistoryEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HistoryEmptyView()
        }
    }
}
