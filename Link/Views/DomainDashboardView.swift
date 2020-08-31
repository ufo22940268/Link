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
    @State var showingAddEndPoint: Bool = false
    @Environment(\.managedObjectContext) var context
    @ObservedObject var addApiData = ApiEditData()
    @EnvironmentObject var domainData: DomainData

    var dataSource: DataSource {
        DataSource(context: context)
    }

    var refreshButton: some View {
        if domainData.endPoints.count > 0 {
            return AnyView(Button(domainData.isLoading ? "刷新中" : "刷新", action: {
                self.domainData.needReload.send()
            }).disabled(domainData.isLoading))
        } else {
            return AnyView(EmptyView())
        }
    }

    var addButton: some View {
        Button(action: {
            self.showingAddEndPoint = true
        }, label: {
            Image(systemName: "plus").padding()
        }).sheet(isPresented: $showingAddEndPoint, onDismiss: {
            self.addApiData.setupForCreate()
            self.domainData.needReload.send()
        }, content: { () -> AnyView in
            AnyView(EndPointEditView(type: .add, apiEditData: self.addApiData)
                .environment(\.managedObjectContext, self.addApiData.context!))
        })
    }

    func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        f.doesRelativeDateFormatting = true
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
            .navigationBarItems(leading: refreshButton, trailing: addButton)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background(Color(UIColor.systemBackground))
        .font(.body)
        .onAppear {
            CoreDataContext.edit.rollback()
        }
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
