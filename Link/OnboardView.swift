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
    @State private var domainData: DomainData = DomainData()
    @Environment(\.managedObjectContext) var context
    @State var cancellables = [AnyCancellable]()

    var body: some View {
        TabView(selection: $selection) {
            DomainDashboardView()
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "cloud.fill")
                        Text("监控")
                    }
                }
                .tag(0)
                .environmentObject(self.domainData)
                .onAppear {
                    self.loadDomains()
                }
                .onReceive(domainData.onAddedDomain) { () in
                    self.loadDomains()
                }
                .onReceive(domainData.onApiWatchChanged) { () in
                    self.loadDomains()
                }
            Text("Second View")
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "person")
                        Text("设置")
                    }
                }
                .tag(1)
        }
    }

    func loadDomains() {
        print("loadDomains", Date())
        let req: NSFetchRequest<EndPointEntity> = EndPointEntity.fetchRequest()
        if let domains = try? context.fetch(req) {
            domainData.endPoints = domains
        } else {
            domainData = DomainData()
        }

        HealthChecker(domains: domainData.endPoints).checkHealth { domains in
            domainData.endPoints = domains
            try? context.save()
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in
            self.domainData.objectWillChange.send()
        }, receiveValue: { _ in })
        .store(in: &cancellables)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardView().colorScheme(.light)
            OnboardView().colorScheme(.dark)
        }
    }
}
