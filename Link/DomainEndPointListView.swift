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

private struct EndPointRow: View {
    var endPoint: EndPointEntity

    var body: some View {
        NavigationLink(destination: JSONViewerView().environment(\.endPointId, endPoint.objectID)) {
            HStack {
                Text(endPoint.endPointPath).lineLimit(1)
                Spacer()
                if endPoint.status == HealthStatus.error.rawValue {
                    Image(systemName: "cloud.rain")
                }
            }
        }
    }
}

struct DomainEndPointListView: View {
    let statuses: [EndPointStatus] = [EndPointStatus(path: "/api/repos/list", status: .healthy), EndPointStatus(path: "/api/members/list", status: .error)]
    @EnvironmentObject var domainData: DomainData

    var domainMap: [String: [EndPointEntity]] {
        domainData.endPoints.filter({ $0.domain?.name != nil }).reduce([String: [EndPointEntity]](), { r, entity in
            var k = r
            let domainName = entity.domain!.name!
            if r[domainName] != nil {
                k[domainName]!.append(entity)
            } else {
                k[domainName] = [entity]
            }
            return k
        })
    }

    var body: some View {
        List {
            ForEach(domainMap.keys.sorted(), id: \.self) { domainName in
                Section(header: Text(domainName).font(.system(.subheadline)).bold().padding([.vertical]), content: {
                    ForEach(self.domainMap[domainName]!.sorted(by: { $0.url ?? "" < $1.url ?? "" })) { endPoint in
                        EndPointRow(endPoint: endPoint)
                    }
                }).font(.body)
            }
        }
    }
}

struct DomainEndPointListView_Previews: PreviewProvider {
    static var previews: some View {
        let de = EndPointEntity(context: context)
        de.url = "https://ewfwef.com/fwef/wefwessff"
        de.status = "healthy"
        let de2 = EndPointEntity(context: context)
        de2.url = "https://ewfwef.com/fwef/22222"
        de2.status = "error"
        return DomainEndPointListView()
            .environment(\.managedObjectContext, getPersistentContainer().viewContext)
    }
}
