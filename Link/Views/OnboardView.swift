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
            .tabItem {
                VStack {
                    Image(systemName: "clock.fill")
                    Text("记录")
                }
            }
    }

    var body: some View {
        ZStack {
            if !domainData.isLogin {
                dashboardView
            } else {
                TabView(selection: $selection) {
                    dashboardView
                        .tag(0)
                    historyView
                        .tag(1)
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
