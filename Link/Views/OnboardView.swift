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

enum OnboardType: Int {
    case dashboard
    case history
    case setting
}

struct OnboardView: View {
    @State private var selection = OnboardType.dashboard
    @ObservedObject private var domainData = DomainData()
    @Environment(\.managedObjectContext) var context
    @State var cancellables = [AnyCancellable]()

    var dataSource: DataSource {
        DataSource(context: context)
    }

    var dashboardView: some View {
        DomainDashboardView()
            .tag(OnboardType.dashboard.rawValue)
            .font(.title)
            .tabItem {
                Label("监控", systemImage: "cloud.fill")
            }
            .environmentObject(self.domainData)
            .onAppear {
                if !DebugHelper.isPreview {
                    self.domainData.needReload.send()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                self.domainData.needReload.send()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.refreshDomain), perform: { _ in
                self.domainData.needReload.send()
            })
            .environmentObject(dataSource)
    }

    var historyView: some View {
        HistoryView()
            .tag(OnboardType.history.rawValue)
            .tabItem {
                Label("记录", systemImage: "clock.fill")
            }
    }

    var settingView: some View {
        SettingView()
            .tabItem {
                Label("更多", systemImage: "ellipsis")
            }
            .environmentObject(domainData)
    }

    var body: some View {
        ZStack {
            if !domainData.isLogin {
                dashboardView
            } else {
                TabView(selection: $selection) {
                    dashboardView
                    historyView
                    settingView
                }
            }
        }
    }
}

struct OnBoardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView().colorScheme(.dark)
    }
}
