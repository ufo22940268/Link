//
//  ApiEditListItemView.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/25.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct ApiListItemView: View {
    @Binding var api: ApiEntity
    @State var activeDetail: Bool = false
    @Environment(\.presentationMode) var presentationMode
    var showDisclosure: Bool
    var dismiss: (() -> Void)?

    init(api: Binding<ApiEntity>, showDisclosure: Bool = true, dismiss: (() -> Void)? = nil) {
        _api = api
        self.showDisclosure = showDisclosure
        self.dismiss = dismiss
    }

    var detailView: some View {
        ApiDetailView(api: api)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text((api.paths ?? "").lastPropertyPath)
                }
                Text(api.paths ?? "").font(.footnote).foregroundColor(.gray)
                    .lineLimit(2)
            }

            Spacer()

            if activeDetail {
                NavigationLink("", destination: detailView, isActive: $activeDetail)
                    .hidden()
            }

            if showDisclosure {
                Button(action: {
                    self.api.watch = true
                    self.api.watchValue = self.api.value
                    self.dismiss?()
                }) {
                    EmptyView()
                }

                Button(action: {
                    self.activeDetail = true
                }, label: { () in
                    Image(systemName: "info.circle").foregroundColor(.accentColor)
                })
                    .buttonStyle(BorderlessButtonStyle())
            }
        }
    }
}

struct ApiEditListItemView_Previews: PreviewProvider {
    static var previews: some View {
//        ApiEditListItemView()
        EmptyView()
    }
}
