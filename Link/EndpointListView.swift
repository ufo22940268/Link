//
//  EndpointListView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/19.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct EndpointListView: View {
    
    let data = [1, 2, 3]
    
    var body: some View {
        List {
            Section(header: Text("Merico").font(.system(.subheadline)).bold().padding([.vertical]), content: {                
                ForEach(1..<10) { i in
                    Text(String(i))
                }
            })
        }
    }
}

struct EndpointListView_Previews: PreviewProvider {
    static var previews: some View {
        EndpointListView()
    }
}
