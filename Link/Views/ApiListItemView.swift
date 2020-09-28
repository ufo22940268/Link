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
    @State var showDetail: Bool = false
    @Environment(\.presentationMode) var presentationMode
    var showDisclosure: Bool
    var dismiss: (() -> Void)?

    init(api: Binding<ApiEntity>, showDisclosure: Bool = true, dismiss: (() -> Void)? = nil) {
        _api = api
        self.showDisclosure = showDisclosure
        self.dismiss = dismiss
    }

    var body: some View {
        HStack {
            Text(api.paths ?? "")

            Spacer()

            if showDisclosure {
                Button(action: {
                    self.showDetail = true
                }, label: { () in
                    Image(systemName: "info.circle").foregroundColor(.accentColor)
                }).buttonStyle(BorderlessButtonStyle())
            }
        }
        .onTapGesture(perform: {
            self.api.watch = true
            self.api.watchValue = self.api.value
            self.dismiss?()
        })
        .sheet(isPresented: $showDetail, content: {
            NavigationView {
                ApiDetailView(api: api)
                    .navigationBarItems(leading: Button("返回") {
                        self.showDetail = false
                    })
            }
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
