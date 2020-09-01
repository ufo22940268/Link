//
//  ApiSectionView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/1.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct ApiSectionView: View {
    var onComplete: () -> Void
    var apis: [ApiEntity]
    var title: String

    var body: some View {
        Section(header: Text(title)) {
            ForEach(self.apis) { api in
                NavigationLink(destination: ApiDetailView(api: api, onComplete: self.onComplete), label: {
                    Text(api.paths ?? "")
                })
            }
        }
    }
}

struct ApiSectionView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
