//
//  EmptyEndPointListView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/29.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct EmptyEndPointListView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "tray").font(.system(size: 60, weight: .light, design: .default))
            Text("请先添加监控点").font(.headline)
        }
        .foregroundColor(.gray)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct EmptyEndPointListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyEndPointListView()
    }
}
