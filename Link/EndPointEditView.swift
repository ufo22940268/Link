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
    
    @Binding var api: ApiEntity
    @Environment(\.editMode) var mode
    var selected: Bool = false
    
    var isEditing: Bool {
        self.mode != nil && self.mode!.wrappedValue.isEditing
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
        NavigationLink(destination: EndPointDetailEditView(api: $api)) {
            innerBody
        }
    }
}

class Context: ObservableObject {
    @Published var selection = Set<Int>()
}

struct EndPointEditListView: View {
    
    let domain: Domain
    @State var apis = [ApiEntity]()
    @State private var cancellables = [AnyCancellable]()
    @Environment(\.managedObjectContext) var objectContext
    @ObservedObject var context: Context = Context()
    
    fileprivate func loadData() {
        if apis.count > 0 {
           return
        }
        
        print("loadData")
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        ApiHelper()
            .fetch(domain: domain)
            .catch { error in Just([]) }
            .receive(on: DispatchQueue.main)
            .sink { apis in
                self.apis = apis
                
                self.context.selection.removeAll()
                for (i, api) in apis.enumerated() {
                    if api.watch {
                        self.context.selection.insert(i)
                    }
                }
                  
                self.context.$selection.sink { (selections) in
                    for index in selections {
                        self.apis[index].watch = true
                    }
//                    self.objectContext.
                    print("update objects", self.objectContext.updatedObjects)
                    try! self.objectContext.save()
                }
                .store(in: &self.cancellables)
        }
        .store(in: &cancellables)
    }
    
    
    var body: some View {
        List(0..<apis.count, id: \.self, selection: $context.selection) { (i: Int) in
            EndPointEditListItemView(api: self.$apis[i], selected: self.context.selection.contains(i))
        }
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
            try! EndPointEditView(domain: getAnyDomain())
        }
    }
}

