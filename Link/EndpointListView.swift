//
//  EndpointListView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/19.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

enum EndpointHealthStatus {
    case healthy
    case error
}

struct EndpointStatus: Hashable {
    let path: String
    let status: EndpointHealthStatus
}

struct EndpointListView: View {
    
    let statuses: [EndpointStatus] = [EndpointStatus(path: "/api/repos/list", status: .healthy), EndpointStatus(path: "/api/members/list", status: .error)]
    
    var body: some View {
        List {
            Section(header: Text("Merico").font(.system(.subheadline)).bold().padding([.vertical]), content: {
                ForEach(statuses, id: \.self) { s in
                    HStack {
                        Text(s.path)
                        Spacer()
                        if s.status == .error {
                            Image(systemName: "cloud.rain")
                        }
                    }
                }
            }).font(.body)
        }
    }
}

struct EndpointListView_Previews: PreviewProvider {
    static var previews: some View {
        EndpointListView()
    }
}
