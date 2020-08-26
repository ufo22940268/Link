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
    case other
    case formatError
}

struct EndPointStatus: Hashable {
    let path: String
    let status: HealthStatus
}

private struct EndPointRow: View {
    var endPoint: EndPointEntity
    @EnvironmentObject var domainData: DomainData
    @Environment(\.managedObjectContext) var context

    var body: some View {
        NavigationLink(destination: JSONViewerView(modelData: JSONViewerData(endPoint: endPoint), context: context)
            .environment(\.endPointId, endPoint.objectID)
            .environmentObject(domainData)
        ) {
            HStack {
                Text(endPoint.endPointPath).lineLimit(1)
                Spacer()
                if endPoint.status == HealthStatus.error {
                    Image(systemName: "cloud.rain")
                } else if endPoint.status == HealthStatus.formatError {
                    Image(systemName: "exclamationmark.icloud")
                }
            }
        }
    }
}

struct DomainEndPointListView: View {
    let statuses: [EndPointStatus] = [EndPointStatus(path: "/api/repos/list", status: .healthy), EndPointStatus(path: "/api/members/list", status: .error)]
    @EnvironmentObject var domainData: DomainData
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var dataSource: DataSource

    var domainMap: [String: [EndPointEntity]] {
        domainData.endPoints.sorted(by: { $0.url ?? "" < $1.url ?? "" }).reduce([String: [EndPointEntity]]()) { r, entity in
            var k = r
            let domainName = dataSource.getDomainName(for: entity.url!)
            if r[domainName] != nil {
                k[domainName]!.append(entity)
            } else {
                k[domainName] = [entity]
            }
            return k
        }
    }

    var domainNames: [String] {
        domainMap.keys.sorted()
    }

    var body: some View {
        List {
            ForEach(domainNames, id: \.self) { domainName in
                Section(header: Text(domainName).font(.system(.subheadline)).bold().padding([.vertical]), content: {
                    ForEach(self.domainMap[domainName]!) { endPoint in
                        EndPointRow(endPoint: endPoint)
                    }
                }).font(.body)
            }
            .onDelete { index in
                let endPoint = self.domainNames.flatMap { self.domainMap[$0]! }[index.first!]
                DataSource(context: self.context).deleteEndPoint(entity: endPoint)
                self.domainData.endPoints.removeAll { $0 == endPoint }
            }
        }
    }
}
