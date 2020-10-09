//
//  HistoryEmptyView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/22.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct LoadableTemplateView: View {
    internal init(systemImage: String, text: String) {
        imageView = Image(systemName: systemImage)
        self.text = text
    }

    var imageView: Image
    var text: String

    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 20) {
            imageView.font(.system(size: 50))
            Text(text).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.secondary)
    }
}

struct LoadableTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
            .preferredColorScheme(.dark)
    }
}
