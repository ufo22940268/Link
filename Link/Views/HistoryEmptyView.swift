//
//  HistoryEmptyView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/22.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct HistoryEmptyView: View {
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 20) {
            Image(systemName: "wand.and.stars.inverse").font(.system(size: 50))
            Text("扫描中").foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.secondary)
    }
}

struct HistoryEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryEmptyView()
            .preferredColorScheme(.dark)
    }
}
