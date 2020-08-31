//
//  ApiEditListItemView.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/25.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct ApiEditListItemView: View {
    @Binding var api: ApiEntity
    @Environment(\.editMode) var mode
    @State var activeDetail: Bool = false
    @Environment(\.presentationMode) var presentationMode
    var segment: Segment
    var onComplete: () -> Void

    var isEditing: Bool {
        mode != nil && mode!.wrappedValue.isEditing
    }

    var detailView: some View {
        ApiDetailView(api: api, onComplete: onComplete)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text((api.paths ?? "").lastPropertyPath).bold()
                }
                Text(api.paths ?? "").font(.footnote).foregroundColor(.gray)
                    .lineLimit(2)
            }

            Spacer()
            if activeDetail {
                NavigationLink("", destination: detailView, isActive: $activeDetail)
                    .hidden()
            }
            
            Button(action: {
                self.api.watch = true
                self.presentationMode.wrappedValue.dismiss()
            }) {
                EmptyView()
            }

            Button(action: {
                print("click")
                self.activeDetail = true
            }, label: { () in
                Image(systemName: "info.circle").foregroundColor(.accentColor)
            })
                .buttonStyle(BorderlessButtonStyle())
        }
    }
}

struct ApiEditListItemView_Previews: PreviewProvider {
    static var previews: some View {
//        ApiEditListItemView()
        EmptyView()
    }
}
