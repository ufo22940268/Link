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
    var segment: Segment
    var onComplete: () -> Void

    var isEditing: Bool {
        mode != nil && mode!.wrappedValue.isEditing
    }

    var body: some View {
        HStack {
            if segment == .all && mode?.wrappedValue != EditMode.active {
                if api.watch {
                    Image(systemName: "star.fill").foregroundColor(.yellow).font(.footnote)
                } else {
                    Text("").font(.footnote).fixedSize().frame(width: 13, height: 1, alignment: .leading)
                }
            } else {
                Text("").font(.footnote).fixedSize().frame(width: 13, height: 1, alignment: .leading)
            }
            NavigationLink(destination: ApiDetailView(api: api, onComplete: onComplete)) {
                VStack(alignment: .leading) {
                    HStack {
                        Text((api.paths ?? "").lastPropertyPath).bold()
                    }
                    Text(api.paths ?? "").font(.footnote).foregroundColor(.gray)
                        .lineLimit(2)
                }
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
