//
//  DashboardView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/18.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI


struct DashboardView: View {
    
    @Binding var domains: [DomainEntity]
    
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
                EndPointListView(domains: self.$domains)
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
        let d = DomainEntity(context: context)
        d.url = "http://wewef.com/ff/aajj"
        return Group {
            DashboardView(domains: Binding.constant([d])).colorScheme(.light)
        }
    }
} 
