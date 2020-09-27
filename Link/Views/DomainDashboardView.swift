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
    @EnvironmentObject var domainData: DomainData

    var dataSource: DataSource {
        DataSource(context: context)
    }

    var refreshButton: some View {
        if domainData.endPoints.count > 0 {
            return AnyView(Button(domainData.isLoading ? "刷新中" : "刷新", action: {
                self.domainData.needReload.send()
                domainData.isLoading = true
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
            return AnyView(VStack(alignment: .leading, spacing: 8) {
                Text("更新时间: \(self.formatDate(lastUpdate))").foregroundColor(.gray)
                if !domainData.isLogin {
                    HStack(spacing: 0) {
                        Text("若要开启监控通知，请先").foregroundColor(.gray)
                        Button("登录") {
                            self.domainData.triggerAppleLogin()
                        }
                    }
                } else {
                    Button("登出") {
                        LoginManager.logout()
                        self.domainData.loginInfo = nil
                    }
                }
            }
            .font(.footnote)
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
        .sheet(isPresented: $showingAddEndPoint, onDismiss: {
            self.domainData.needReload.send()
        }, content: { () -> AnyView in
            return AnyView(EndPointEditView(type: .add)
                            .environment(\.managedObjectContext, CoreDataContext.add))
        })
        .navigationViewStyle(StackNavigationViewStyle())
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
