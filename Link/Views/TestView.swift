//
//  TestView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/27.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        
        NavigationView {
            List {
                ForEach(0 ..< 3) { _ in
                    NavigationLink(destination: Text("Target")) {
                        Text("jjjjjj")
                    }
                }
            }
        }
    }
    
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
