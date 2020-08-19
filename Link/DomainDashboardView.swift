//
//  DashboardView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/18.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import CoreData
import SwiftUI

struct DomainDashboardView: View {
    @EnvironmentObject var domainData: DomainData

    var refreshButton: some View {
        Button(domainData.isLoading ? "刷新中" : "刷新", action: {
            self.domainData.needReload.send()
        })
            .disabled(domainData.isLoading)
    }

    var addEndPointButton: some View {
        NavigationLink(destination: EndPointEditView(type: .add), label: {
            Image(systemName: "plus")
        })
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 15) {
                    DomainStatisticsBlockView(status: .healthy(count: domainData.healthyCount()))
                    DomainStatisticsBlockView(status: .error(count: domainData.errorCount()))
                }.padding()
                DomainEndPointListView()
            }
            .navigationBarTitle(Text("概览"))
            .navigationBarItems(leading: refreshButton, trailing: addEndPointButton)
        }
        .background(Color(UIColor.systemBackground))
        .font(.body)
    }
}

struct DomainDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let dd = DomainData()
        dd.endPoints = try! context.fetch(EndPointEntity.fetchRequest() as NSFetchRequest<EndPointEntity>)
        return Group {
            DomainDashboardView().colorScheme(.light)
        }
        .environment(\.managedObjectContext, context)
        .environmentObject(dd)
    }
}
