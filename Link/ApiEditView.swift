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
    @Environment(\.managedObjectContext) var context
    @ObservedObject var apiEditData: ApiEditData
    @EnvironmentObject var domainData: DomainData
    @Binding var dismissPresentationMode: PresentationMode?

    var doneButton: some View {
        Button("完成", action: {
            try? self.context.save()
            self.dismissPresentationMode?.dismiss()
        })
    }

    var body: some View {
        List {
            ForEach(self.apiEditData.apis.indices, id: \.self) { i in
                ApiEditListItemView(api: self.$apiEditData.apis[i], selected: self.apiEditData.apis[i].watch)
            }
        }
        .navigationBarItems(trailing: doneButton)
    }
}

struct ApiEditView_Previews: PreviewProvider {
    static var previews: some View {
        ApiEditView(apiEditData: ApiEditData(), dismissPresentationMode: Binding.constant(nil))
    }
}
