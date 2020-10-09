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
    @EnvironmentObject var domainData: LinkData

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

    @ViewBuilder var leadingButton: some View {
        if !BackendAgent().isLogin && domainData.endPoints.isEmpty {
            loginButton
        } else if !domainData.endPoints.isEmpty {
            refreshButton
        } else {
            EmptyView()
        }
    }

    var loginButton: some View {
        Button("登录") {
            self.domainData.triggerAppleLogin()
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

    @ViewBuilder var lastUpdateView: some View {
        if let lastUpdate = domainData.lastUpdateTime {
            VStack(alignment: .leading, spacing: 8) {
                Text("更新时间: \(self.formatDate(lastUpdate))").foregroundColor(.gray)
                if !domainData.isLogin {
                    HStack(spacing: 0) {
                        Text("若要开启监控通知，请先").foregroundColor(.gray)
                        Button("登录") {
                            self.domainData.triggerAppleLogin()
                        }
                    }
                }
            }
            .font(.footnote)
            .padding(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            EmptyView()
        }
    }

    var headerView: some View {
        VStack {
            HStack(spacing: 15) {
                DomainStatisticsBlockView(status: .healthy(count: domainData.healthyCount()))
                DomainStatisticsBlockView(status: .error(count: domainData.errorCount()))
            }.padding()
            lastUpdateView
        }
    }

    var body: some View {
            Group {
                if domainData.endPoints.isEmpty {
                    EmptyEndPointListView()
                } else {
                    List {
                        headerView
                        EndPointListView()
                    }
                    .listStyle(GroupedListStyle())
                }
            }
            .navigationBarTitle(Text("概览"))
            .navigationBarItems(leading: leadingButton, trailing: addButton)
        .sheet(isPresented: $showingAddEndPoint, onDismiss: {
            self.domainData.needReload.send()
        }, content: { () in
            EndPointEditView(type: .add)
                .environment(\.managedObjectContext, CoreDataContext.add)
        })
        .font(.body)
        .onAppear {
            CoreDataContext.edit.rollback()
        }
		.tag(OnboardType.dashboard.rawValue)
		.font(.title)
		.onAppear {
			if !DebugHelper.isPreview {
				self.domainData.needReload.send()
			}
		}
//            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
//                self.domainData.needReload.send()
//            }
		.onReceive(NotificationCenter.default.publisher(for: Notification.refreshDomain), perform: { _ in
			self.domainData.needReload.send()
		})

    }
}

struct DomainDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let dd = LinkData()
        dd.endPoints = try! context.fetch(EndPointEntity.fetchRequest() as NSFetchRequest<EndPointEntity>)
        return Group {
            DomainDashboardView().colorScheme(.dark)
        }
        .environment(\.managedObjectContext, context)
        .environmentObject(dd)
    }
}
