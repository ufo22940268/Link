//
//  ContentView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/16.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selection = 0
    @State private var domainData: DomainData = DomainData()
    @Environment(\.managedObjectContext) var context
     
    var body: some View {
        TabView(selection: $selection){
            DashboardView()
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
        let req: NSFetchRequest<DomainEntity> = DomainEntity.fetchRequest()
        if let domains = try? context.fetch(req) {
            domainData.domains = domains
        } else {
            domainData = DomainData()
        }
        
        HealthChecker(domains: domainData.domains).checkHealth { domains in
            domainData.domains = domains
            domainData.objectWillChange.send()
        }

        domainData.objectWillChange.send()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().colorScheme(.light)
            ContentView().colorScheme(.dark)
        }
    }
}
	
