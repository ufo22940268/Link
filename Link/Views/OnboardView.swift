//
//  ContentView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/16.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

struct OnboardView: View {
    @State private var selection = 0
    @ObservedObject private var domainData = DomainData()
    @Environment(\.managedObjectContext) var context
    @State var cancellables = [AnyCancellable]()

    var dataSource: DataSource {
        DataSource(context: context)
    }

    var dashboardView: some View {
        DomainDashboardView()
            .font(.title)
            .tabItem {
                VStack {
                    Image(systemName: "cloud.fill")
                    Text("监控")
                }
            }
            .environmentObject(self.domainData)
            .onAppear {
                if !DebugHelper.isPreview {
                    self.domainData.needReload.send()
                }
            }
            .onReceive(domainData.needReload) { () in
                self.loadDomains()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                self.loadDomains()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.refreshDomain), perform: { _ in
                self.loadDomains()
            })
            .environmentObject(dataSource)
    }

    var historyView: some View {
        HistoryView()
            .tabItem {
                VStack {
                    Image(systemName: "clock.fill")
                    Text("历史")
                }
            }
    }

    var body: some View {
        ZStack {
            if !domainData.isLogin {
                dashboardView
            } else {
                TabView {
                    dashboardView
                        .tag(0)
                    historyView
                        .tag(1)
                }
            }
        }
    }

    func loadDomains() {
        print("loadDomains")
        let req: NSFetchRequest<EndPointEntity> = EndPointEntity.fetchRequest()
        if let domains = try? context.fetch(req).filter({ $0.url != nil }) {
            domainData.endPoints = domains
        } else {
            domainData.endPoints = []
        }

        domainData.isLoading = true
        guard !domainData.endPoints.isEmpty else { return }
        HealthChecker(domains: domainData.endPoints, context: context)
            .checkHealth()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                self.domainData.lastUpdateTime = Date()
                self.domainData.objectWillChange.send()
                self.domainData.isLoading = false
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}

struct OnBoardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView().colorScheme(.dark)
    }
}
