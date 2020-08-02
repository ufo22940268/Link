//
//  EndPointDetailEditView.swift
//  Link
//
//  Created by Frank Cheng on 2020/7/31.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct ApiDetailEditView: View {
    
    @Binding var api: ApiEntity
    @Binding var isOn: Bool
    
    init(api: Binding<ApiEntity>) {
        _api = api
        _isOn = api.watch
    }
        
    var body: some View {
        List {
            Section {
                Toggle("开启", isOn: $isOn)
            }
            Section (header: Text("Key")) {
                Text(api.paths ?? "")
            }
            
            Section (header: Text("value")) {
                Text(api.value ?? "")
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text("字段"), displayMode: .inline)
    }
}

struct ApiDetailEditView_Previews: PreviewProvider {
    
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        
        @State var api: ApiEntity = ApiEntity(context: getPersistentContainer().viewContext)
        
        var body: some View {
            api.paths = "asaa"
            api.value = "vvv"
            return ApiDetailEditView(api: $api).environment(\.colorScheme, .dark)
        }
    }
}
