//
//  FailedView.swift
//  Link
//
//  Created by Frank Cheng on 2020/10/7.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct LoadableFailedView: View {
    var body: some View {
        LoadableTemplateView(systemImage: "wifi.exclamationmark", text: "网络异常")
    }
}

struct LoadableFailedView_Previews: PreviewProvider {
    static var previews: some View {
        LoadableFailedView()
    }
}
