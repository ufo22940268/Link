//
//  ApiEditListItemView.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/25.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

enum ApiListItemType {
    case view
    case edit
}

struct ApiListItemView: View {
    @Binding var api: ApiEntity
    @State var showDetail: Bool = false
    @Environment(\.presentationMode) var presentationMode
    var dismiss: (() -> Void)?

    private var itemType: ApiListItemType

    init(api: Binding<ApiEntity>, showDisclosure: Bool = true, dismiss: (() -> Void)? = nil) {
        _api = api

        if showDisclosure {
            itemType = .edit
        } else {
            itemType = .view
        }

        self.dismiss = dismiss
    }

    var body: some View {
        var view: AnyView = HStack {
            Text(api.paths ?? "")

            Spacer()

            if itemType == .edit {
                Button(action: {
                    self.showDetail = true
                }, label: { () in
                    Image(systemName: "info.circle")
                        .foregroundColor(.accentColor)
                }).buttonStyle(BorderlessButtonStyle())
            }
        }
        .contentShape(Rectangle())
        .sheet(isPresented: $showDetail, content: {
            NavigationView {
                ApiDetailView(api: api)
                    .navigationBarItems(leading: Button("返回") {
                        self.showDetail = false
                    })
            }
        }).anyView()

        if itemType == .edit {
            view = view.onTapGesture(perform: {
                self.api.watch = true
                self.api.watchValue = self.api.value
                self.dismiss?()
            })
                .anyView()
        }
        return view
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
