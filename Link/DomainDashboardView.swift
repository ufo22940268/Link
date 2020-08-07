//
//  DashboardView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/18.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI



struct DomainDashboardView: View {

    @EnvironmentObject var domainData: DomainData    
    
    var addEndPointButton: some View {
        NavigationLink("添加监控", destination: EndPointEditView())
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 15) {
                    DomainStatisticsBlockView(status: .healthy(count: domainData.healthyCount()))
                    DomainStatisticsBlockView(status: .error(count: domainData.errorCount()))
                }.padding()
                DomainEndPointListView()
            }
            .navigationBarTitle(Text("概览"))
            .navigationBarItems(trailing: addEndPointButton)

        }
        .background(Color(UIColor.systemBackground))
        .font(.body)
    }
}

struct DomainDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let d = EndPointEntity(context: context)
        d.url = "http://wewef.com/ff/aajjk"
        let dd = DomainData()
        dd.endPoints = [d]
        return Group {
            DomainDashboardView().colorScheme(.light)
        }.environmentObject(dd)
    }
} 
