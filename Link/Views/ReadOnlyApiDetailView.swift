//
//  EndPointDetailEditView.swift
//  Link
//
//  Created by Frank Cheng on 2020/7/31.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import SwiftUI

struct ReadOnlyApiDetailView: View {
    
    var watchField: RecordItem.WatchField
    
    var body: some View {
        List {
            Section(header: Text("Key")) {
                Text(watchField.path)
            }

            Section(header: Text("value")) {
                Text(watchField.value)
                    .foregroundColor(watchField.match ? nil : .error)
            }
            
            Section(header: Text("期望值")) {
                Text(watchField.watchValue)
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct ReadOnlyApiDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ReadOnlyApiDetailView(watchField: testRecordItem.fields.first!)
    }
}
