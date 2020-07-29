//
//  EndPointEditView.swift
//  Link
//
//  Created by Frank Cheng on 2020/7/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI
import Combine

struct EditButton: View {
    var action: (EditMode?) -> Void
    @Binding var editMode: EditMode
    
    var body: some View {
        Button(action: {
            withAnimation {
                if self.editMode.isEditing == false {
                    self.editMode = EditMode.active
                } else {
                    self.editMode = EditMode.inactive
                }
            }
        }) {
            Text(self.editMode.isEditing == false ? "Edit" : "Done")
        }
    }
}

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
        
        //Animation wired.
//        if isEditing {
//            return AnyView(innerBody)
//        } else {
//            return AnyView(NavigationLink(destination: EmptyView()) {
//                innerBody
//            })
//        }
    }
}

struct EndPointEditListView: View {
    
    @State var apis = [Api]()
    @State private var c : AnyCancellable?
    @State  var selection = Set<Int>()
    @Binding var mode: EditMode
    
    fileprivate func loadData() {
        self.c = ApiHelper().fetch()
            .catch { error in
                return Just([])
        }
        .receive(on: DispatchQueue.main)
        .assign(to: \EndPointEditListView.apis, on: self)
    }
    
    var body: some View {
        List(0..<apis.count, id: \.self, selection: $selection) { (i: Int) in
            EndPointEditListItemView(api: self.$apis[i])
        }
        .environment(\.editMode, self.$mode)
        .onAppear {
            self.loadData()
        }
    }
}

struct EndPointEditView: View {
    
    @State var mode: EditMode
    
    var body:  some View {
        EndPointEditListView(mode: $mode).navigationBarItems(trailing: EditButton(action: { _ in }, editMode: self.$mode))
    }
}

struct EndPointEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EndPointEditView(mode: EditMode.inactive)
        }
    }
}

