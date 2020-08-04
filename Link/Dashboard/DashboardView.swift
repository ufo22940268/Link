//
//  DashboardView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/18.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI



struct DashboardView: View {

    @EnvironmentObject var domainData: DomainData    
    
    var addEndPointButton: some View {
        NavigationLink("添加监控", destination: DomainEditView())
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 15) {
                    StatisticsBlockView(status: .healthy(count: 8))
                    StatisticsBlockView(status: .error(count: 2))
                }.padding()
                EndPointListView()
            }
            .navigationBarTitle(Text("概览"))
            .navigationBarItems(trailing: addEndPointButton)

        }
        .background(Color(UIColor.systemBackground))
        .font(.body)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let d = EndPointEntity(context: context)
        d.url = "http://wewef.com/ff/aajjk"
        let dd = DomainData()
        dd.domains = [d]
        return Group {
            DashboardView().colorScheme(.light)
        }.environmentObject(dd)
    }
} 
