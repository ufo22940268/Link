//
//  EndPointDetailEditView.swift
//  Link
//
//  Created by Frank Cheng on 2020/7/31.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct EndPointDetailEditView: View {
    
    @State var isOn: Bool = false
    var api: Api
    
    init(api: Api) {
        self.api = api
        _isOn = State(initialValue: api.watch)
    }
    
    var body: some View {
        List {
            Section {
                Toggle("开启", isOn: self.$isOn)
            }
            Section (header: Text("Key")) {
                Text(api.path)
            }
            
            Section (header: Text("value")) {
                Text(api.value ?? "")
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct EndPointDetailEditView_Previews: PreviewProvider {
    static var previews: some View {
        EndPointDetailEditView(api: Api(path: "wefwef.wefwefef", value: "asdfasdfvvvvv",  watch: true))
            .environment(\.colorScheme, .dark)
    }
}
