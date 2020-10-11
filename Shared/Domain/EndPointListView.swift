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
	@EnvironmentObject var domainData: LinkData
	@Environment(\.managedObjectContext) var context

	var body: some View {
		NavigationLink(destination: EndPointDetailView(endPoint: endPoint, context: context)
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

struct EndPointListView: View {
	@EnvironmentObject var domainData: LinkData
	@Environment(\.managedObjectContext) var context

	var dataSource: DataSource {
		DataSource(context: context)
	}

	var domainMap: [String: [EndPointEntity]] {
		domainData.endPoints.filter { $0.url != nil }.sorted(by: { $0.url ?? "" < $1.url ?? "" }).reduce([String: [EndPointEntity]]()) { r, entity in
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
		ForEach(domainNames, id: \.self) { domainName in
			Section(header: Text(domainName).font(.system(.subheadline)).bold().textCase(.lowercase), content: {
				ForEach(self.domainMap[domainName]!) { endPoint in
					EndPointRow(endPoint: endPoint)
						.paddingMacOS()
				}
				.onDelete { index in
					let endPoint: EndPointEntity = self.domainMap[domainName]![index.first!]
					let url = endPoint.url!
					DataSource(context: self.context).deleteEndPoint(entity: endPoint)
					let agent = BackendAgent()
					if agent.isLogin {
						self.domainData.deleteEndPoint(by: url)
					}
					self.domainData.endPoints.removeAll { $0 == endPoint }
				}
			}).font(.body)
		}
	}
}

struct EndPointListView_Previews: PreviewProvider {
	static var previews: some View {
		EndPointListView()
			.environmentObject(LinkData())
			.environmentObject(DataSource(context: context))
			.environment(\.managedObjectContext, context)
	}
}
