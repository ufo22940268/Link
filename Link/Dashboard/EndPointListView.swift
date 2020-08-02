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

struct EndPointStatus: Hashable {
    let path: String
    let status: EndpointHealthStatus
}

struct EndPointListView: View {
    
    let statuses: [EndPointStatus] = [EndPointStatus(path: "/api/repos/list", status: .healthy), EndPointStatus(path: "/api/members/list", status: .error)]
    @Binding var domains: [DomainEntity]
    
    var body: some View {
        List {
            Section(header: Text("Merico").font(.system(.subheadline)).bold().padding([.vertical]), content: {
                ForEach(domains) { s in
                    HStack {
                        Text(s.endPointPath)
                        Spacer()
//                        if s.status == .error {
//                            Image(systemName: "cloud.rain")
//                        }
                    }
                }
            }).font(.body)
        }
    }
}

struct EndpointListView_Previews: PreviewProvider {
    static var previews: some View {
        let de = DomainEntity(context: context)
        de.url = "https://ewfwef.com/fwef/wefwessf"
        return EndPointListView(domains: Binding.constant([de, de]))
    }
}
