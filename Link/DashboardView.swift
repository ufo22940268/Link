//
//  DashboardView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/18.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI


struct DashboardView: View {
    
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
                EndpointListView()
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
        Group {
            DashboardView().colorScheme(.light)
            DashboardView().colorScheme(.dark).preferredColorScheme(.dark)
        }
    }
} 
