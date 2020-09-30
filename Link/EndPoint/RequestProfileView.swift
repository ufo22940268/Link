//
//  RequestProfileView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/30.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct ResponseLog {
    var header: String
    var body: String
}

struct RequestProfileView: View {
    var log: ResponseLog

    var body: some View {
        List {
            Section(header: Text("Response Header")) {
                Text(log.header).font(.caption)
            }

            Section(header: Text("Response Body")) {
                Text(log.body).font(.caption)
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct RequestProfileView_Previews: PreviewProvider {
    static var previews: some View {
        RequestProfileView(log: TestData.responseLog)
    }
}
