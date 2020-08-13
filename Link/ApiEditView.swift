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
        NavigationLink(destination: ApiDetailEditView(api: $api)) {
            innerBody
        }
    }
}

class ApiEditData: ObservableObject {
    @Published var selection = Set<Int>()
    @Published var apis = [ApiEntity]()
}

struct ApiEditView: View {
    @State private var cancellables = [AnyCancellable]()
    @Environment(\.managedObjectContext) var objectContext
    @ObservedObject var apiEditData: ApiEditData
    @Environment(\.endPointId) var endPointId

    var body: some View {
        Section(header: Text("接口")) {
            Group {
                ForEach(apiEditData.apis.indices, id: \.self) { i in
                    ApiEditListItemView(api: self.$apiEditData.apis[i], selected: self.apiEditData.apis[i].watch)
                }
            }
        }
        .onAppear {
            self.apiEditData.$selection.sink { selections in
                for index in selections {
                    self.apiEditData.apis[index].watch = true
                    self.apiEditData.apis[index].watchValue = self.apiEditData.apis[index].value
                }

                if self.objectContext.updatedObjects.count > 0 {
//                    self.domainData.onApiWatchChanged.send()
                }
                try! self.objectContext.save()
            }.store(in: &self.cancellables)
        }
    }
}

struct ApiEditView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
