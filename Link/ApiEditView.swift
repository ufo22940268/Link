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

struct ApiEditListItemView: View {
    
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
        NavigationLink(destination: ApiDetailEditView(api: $api)) {
            innerBody
        }
    }
}

class Context: ObservableObject {
    @Published var selection = Set<Int>()
}

struct ApiEditListView: View {
    
    let domain: DomainEntity
    @State var apis = [ApiEntity]()
    @State private var cancellables = [AnyCancellable]()
    @Environment(\.managedObjectContext) var objectContext
    @ObservedObject var context: Context = Context()
    
    fileprivate func updateSelection() {
        self.context.selection.removeAll()
        for (i, api) in self.apis.enumerated() {
            if api.watch {
                self.context.selection.insert(i)
            }
        }
    }
    
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
                
                self.updateSelection()
                  
                self.context.$selection.sink { (selections) in
                    for index in selections {
                        self.apis[index].watch = true
                    }
                    try! self.objectContext.save()
                }
                .store(in: &self.cancellables)
        }
        .store(in: &cancellables)
    }
    
    
    var body: some View {
        List(0..<apis.count, id: \.self, selection: $context.selection) { (i: Int) in
            ApiEditListItemView(api: self.$apis[i], selected: self.context.selection.contains(i))
        }
        .onAppear {
            self.loadData()
            self.updateSelection()
        }
    }
}

struct EndPointEditView: View {
    
    var domain: DomainEntity
    
    var body: some View {
        ApiEditListView(domain: domain).navigationBarItems(trailing: EditButton())
    }
}


struct EndPointEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            try! EndPointEditView(domain: getAnyDomain())
        }
    }
}

