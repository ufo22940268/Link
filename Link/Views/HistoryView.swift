//
//  HIstoryView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct HistoryView: View {
    var contentView: some View {
        VStack(spacing: 20) {
            Text("logined")
            Button("logout") {
                LoginManager.logout()
            }
        }
    }

    var body: some View {
        ZStack {
            contentView
        }
    }
}

struct HIstoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
