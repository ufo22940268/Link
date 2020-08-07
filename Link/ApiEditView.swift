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

struct ApiEditListView: View {
    let domain: EndPointEntity
    @State var apis = [ApiEntity]()
    @State private var cancellables = [AnyCancellable]()
    @Environment(\.managedObjectContext) var objectContext
    @ObservedObject var context: Context = Context()
    @Environment(\.endPointId) var endPointId

    fileprivate func updateSelection() {
        context.selection.removeAll()
        for (i, api) in apis.enumerated() {
            if api.watch {
                context.selection.insert(i)
            }
        }
    }

    fileprivate func loadData() {
        if apis.count > 0 {
            return
        }

        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        ApiHelper()
            .fetch(endPoint: domain)
            .catch { _ in Just([]) }
            .receive(on: DispatchQueue.main)
            .sink { apis in
                self.apis = apis
                self.updateSelection()
                self.context.$selection.sink { selections in
                    print("selection updated")
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
        List(0 ..< apis.count, id: \.self, selection: $context.selection) { (i: Int) in
            ApiEditListItemView(api: self.$apis[i], selected: self.context.selection.contains(i))
        }
        .onAppear {
            if !DebugHelper.isPreview {
                self.loadData()
            }
            self.updateSelection()
        }
    }
}

struct ApiEditView: View {
    var domain: EndPointEntity

    var body: some View {
        ApiEditListView(domain: domain)
            .navigationBarItems(trailing: EditButton())
            .navigationBarTitle("接口")
    }
}

struct ApiEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            try! ApiEditView(domain: getAnyEndPoint())
        }
    }
}
