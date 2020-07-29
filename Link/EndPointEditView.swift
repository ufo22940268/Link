//
//  EndPointEditView.swift
//  Link
//
//  Created by Frank Cheng on 2020/7/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI
import Combine

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
    @Published var selelection = Set<Int>()
}

struct EndPointEditListView: View {
    
    @State var apis = [Api]()
    @State private var c : AnyCancellable?
    @State private var c2 : AnyCancellable?
    @State  var selection = Set<Int>()
    @Environment(\.editMode) var mode
    @ObservedObject var context: Context = Context()
        
    fileprivate func loadData() {
        self.c = ApiHelper().fetch()
            .catch { error in
                return Just([])
        }
        .receive(on: DispatchQueue.main)
        .assign(to: \EndPointEditListView.apis, on: self)
        
        self.c2 = context.$selelection.sink { (selections) in
            print(selections)
        }
    }
    
    var body: some View {
        List(0..<apis.count, id: \.self, selection: $context.selelection) { (i: Int) in
            EndPointEditListItemView(api: self.$apis[i])
        }
        .environment(\.editMode, self.mode)
        .onAppear {
            self.loadData()
        }
    }
}

struct EndPointEditView: View {
    
    var body: some View {
        EndPointEditListView().navigationBarItems(trailing: EditButton())
    }
}


struct EndPointEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EndPointEditView()
        }
    }
}

