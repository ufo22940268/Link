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

class Context: ObservableObject {
    @Published var selection = Set<Int>()
}

struct ApiEditView: View {
    @Binding var apis: [ApiEntity] 
    @State private var cancellables = [AnyCancellable]()
    @Environment(\.managedObjectContext) var objectContext
    @ObservedObject var context: Context = Context()
    @Environment(\.endPointId) var endPointId
    @EnvironmentObject var domainData: DomainData

    var endPoint: EndPointEntity {
        domainData.endPoints.first(where: { $0.objectID == self.endPointId })!
    }

    fileprivate func loadData() {
        if apis.count > 0 {
            return
        }

        if endPointId == nil {
            apis = []
            return
        }

        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        ApiHelper()
            .fetch(endPoint: endPoint)
            .catch { _ in Just([]) }
            .receive(on: DispatchQueue.main)
            .sink { apis in
                self.apis = apis
                self.context.$selection.sink { selections in
                    for index in selections {
                        self.apis[index].watch = true
                        self.apis[index].watchValue = self.apis[index].value
                    }
                    try! self.objectContext.save()
                }
                .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }

    var body: some View {
        Section(header: Text("接口")) {
            Group {
                ForEach(0 ..< apis.count, id: \.self) { i in
                    ApiEditListItemView(api: self.$apis[i], selected: self.apis[i].watch)
                }
            }
        }
        .onAppear {
            self.context.$selection.sink { selections in
                for index in selections {
                    self.apis[index].watch = true
                    self.apis[index].watchValue = self.apis[index].value
                }
                try! self.objectContext.save()
            }
        }
    }
}

struct ApiEditView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
