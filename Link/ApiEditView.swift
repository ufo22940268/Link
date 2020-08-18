//
//  EndPointEditView.swift
//  Link
//
//  Created by Frank Cheng on 2020/7/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

struct ApiEditListItemView: View {
    @Binding var api: ApiEntity
    @Environment(\.editMode) var mode
    var selected: Bool = false

    var isEditing: Bool {
        mode != nil && mode!.wrappedValue.isEditing
    }

    var innerBody: some View {
        var text = Text(api.paths ?? "")
        if selected {
            text = text.bold()
                .foregroundColor(.accentColor)
        }
        return text
    }

    var body: some View {
        NavigationLink(destination: ApiDetailView(api: $api)) {
            innerBody
        }
    }
}

class ApiEditData: ObservableObject {
    @Published var apis = [ApiEntity]()
}

struct ApiEditView: View {
    @State private var cancellables = [AnyCancellable]()
    @Environment(\.managedObjectContext) var objectContext
    @ObservedObject var apiEditData: ApiEditData
    @Environment(\.endPointId) var endPointId
    @EnvironmentObject var domainData: DomainData

    var body: some View {
        Section(header: Text("接口")) {
            Group {
                ForEach(self.apiEditData.apis.indices, id: \.self) { i in
                    ApiEditListItemView(api: self.$apiEditData.apis[i], selected: self.apiEditData.apis[i].watch)
                }
            }
        }
    }
}

struct ApiEditView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
