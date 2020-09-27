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
            Text(api.paths ?? "")

//            Spacer()

//            if activeDetail {
//                NavigationLink("", destination: detailView, isActive: $activeDetail)
//                    .hidden()
//            }

//            if showDisclosure {
//                Button(action: {
//                    self.api.watch = true
//                    self.api.watchValue = self.api.value
//                    self.dismiss?()
//                }) {
//                    EmptyView()
//                }
//
//                Button(action: {
//                    self.activeDetail = true
//                }, label: { () in
//                    Image(systemName: "info.circle").foregroundColor(.accentColor)
//                })
//                    .buttonStyle(BorderlessButtonStyle())
//            }
        }.onTapGesture(perform: {
            self.api.watch = true
            self.api.watchValue = self.api.value
            self.dismiss?()
        })
    }
}

struct ApiListItemView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(TestData.apiEntities.map { api -> ApiEntity in
                api.paths = "sdfwefweoifjwoiefj.wefoiwjefoiwjef.wefowijefoij"
                return api
            }, id: \.self.paths) { api in
                ApiListItemView(api: Binding.constant(api))
            }
        }
    }
}
