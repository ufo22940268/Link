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
    
    var api: Api
    
    @Environment(\.editMode) var mode
    var body: some View {
        NavigationLink(destination: EmptyView()) {
            Text((self.mode != nil && self.mode!.wrappedValue.isEditing) ? "active" : "inactive")
//            if self.editMode.wrappedValue ?? false {
//                Text(self.api.paths.last ?? "")
//            } else {
//                /*@START_MENU_TOKEN@*/EmptyView()/*@END_MENU_TOKEN@*/
//            }
        }
    }
        
}

struct EndPointEditListView: View {
            
    @State var apis: [Api] = [Api]()
    @State private var c : AnyCancellable?
    @Environment(\.editMode) var mode

    fileprivate func loadData() {
        self.c = ApiHelper().fetch()
            .catch { error in
                return Just([])
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \EndPointEditListView.apis, on: self)
    }
    
    var body: some View {
        List(0..<3, id: \.self) { (i: Int) in
            EndPointEditListItemView(api: Api(paths: ["asdf" ]))
                .environment(\.editMode, self.mode)
        }
        .onAppear {
            self.loadData()
        }
    }
}

struct EndPointEditView: View {
    var body:  some View {
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
 
