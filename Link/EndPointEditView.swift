//
//  EndPointEditView.swift
//  Link
//
//  Created by Frank Cheng on 2020/7/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

struct EndPointEditListItemView: View {
    
    @Binding var api: Api
    @Environment(\.editMode) var mode
    
    var isEditing: Bool {
        self.mode != nil && self.mode!.wrappedValue.isEditing
    }
    
    var innerBody: some View {
        Text(api.paths.last ?? "")
            .foregroundColor(self.api.watch ? Color.accentColor : Color.primary)
    }
    
    var body: some View {
        NavigationLink(destination: EmptyView()) {
            innerBody
        }
    }
}

class Context: ObservableObject {
    @Published var selection = Set<Int>()
}

struct EndPointEditListView: View {
    
    let domain: Domain
    @State var apis = [Api]()
    @State private var cancellables = [AnyCancellable]()
    @Environment(\.editMode) var mode
    @Environment(\.managedObjectContext) var objectContext
    @ObservedObject var context: Context = Context()
    
    fileprivate func loadData() {
        ApiHelper().fetch()
            .catch { error in
                return Just([])
        }
        .receive(on: DispatchQueue.main)
        .sink { apis in
            self.apis = apis
            
            let req = persistentContainer.managedObjectModel.fetchRequestFromTemplate(withName: "FetchApiByDomain", substitutionVariables: ["domain": self.domain.objectID])
            if let dbApis = try? self.objectContext.fetch(req!) as? [ApiEntity] {
                for selectedApi in dbApis {
                    if let index = self.apis.firstIndex(where: { $0.path == selectedApi.paths }) {
                        self.context.selection.insert(index)
                    }
                }
            }
            
            self.context.$selection.sink { (selections) in
                for index in selections {
                    let api = self.apis[index]
                    let ae = ApiEntity(context: self.objectContext)
                    ae.paths = api.paths.joined(separator: ".")
                    ae.watch = true
                    ae.domain = self.domain
                    try? self.objectContext.save()
                }
            }
            .store(in: &self.cancellables)
        }
        .store(in: &cancellables)
    }
    
    
    var body: some View {
        List(0..<apis.count, id: \.self, selection: $context.selection) { (i: Int) in
            EndPointEditListItemView(api: self.$apis[i])
        }
        .environment(\.editMode, self.mode)
        .onAppear {
            self.loadData()
        }
    }
}

struct EndPointEditView: View {
    
    var domain: Domain
    
    var body: some View {
        EndPointEditListView(domain: domain).navigationBarItems(trailing: EditButton())
    }
}


struct EndPointEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EndPointEditView(domain: getAnyDomain())
        }
    }
}

