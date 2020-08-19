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
    
    func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f.string(from: date)
    }

    var lastUpdateView: some View {
        if let lastUpdate = domainData.lastUpdateTime {
            return AnyView(VStack(alignment: .leading) {
                Text("更新时间: \(self.formatDate(lastUpdate))").font(.footnote).foregroundColor(.gray)
            }
            .padding(.leading)
            .frame(maxWidth: .infinity, alignment: .leading))
        } else {
            return AnyView(EmptyView())
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 15) {
                    DomainStatisticsBlockView(status: .healthy(count: domainData.healthyCount()))
                    DomainStatisticsBlockView(status: .error(count: domainData.errorCount()))
                }.padding()
                lastUpdateView
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
        dd.lastUpdateTime = Date()
        dd.endPoints = try! context.fetch(EndPointEntity.fetchRequest() as NSFetchRequest<EndPointEntity>)
        return Group {
            DomainDashboardView().colorScheme(.dark)
        }
        .environment(\.managedObjectContext, context)
        .environmentObject(dd)
    }
}
