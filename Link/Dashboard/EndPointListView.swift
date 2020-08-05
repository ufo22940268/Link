//
//  EndpointListView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/19.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

enum HealthStatus: String, RawRepresentable {
    case healthy
    case error
}

struct EndPointStatus: Hashable {
    let path: String
    let status: HealthStatus
}

struct EndPointListView: View {
    let statuses: [EndPointStatus] = [EndPointStatus(path: "/api/repos/list", status: .healthy), EndPointStatus(path: "/api/members/list", status: .error)]
    @EnvironmentObject var domainData: DomainData

    var body: some View {
        return List {
            Section(header: Text("Merico").font(.system(.subheadline)).bold().padding([.vertical]), content: {
                ForEach(domainData.endPoints) { endPoint in
                    NavigationLink(destination: JSONViewerView(json: endPoint.data).environmentObject(EndPointData(endPoint: endPoint))) {
                        HStack {
                            Text(endPoint.endPointPath)
                            Spacer()
                            if endPoint.status == HealthStatus.error.rawValue {
                                Image(systemName: "cloud.rain")
                            }
                        }
                    }
                }
            }).font(.body)
        }
    }
}

struct EndPointListView_Previews: PreviewProvider {
    static var previews: some View {
        let de = EndPointEntity(context: context)
        de.url = "https://ewfwef.com/fwef/wefwessff"
        de.status = "healthy"
        let de2 = EndPointEntity(context: context)
        de2.url = "https://ewfwef.com/fwef/22222"
        de2.status = "error"
        return EndPointListView()
            .environment(\.managedObjectContext, getPersistentContainer().viewContext)
    }
}