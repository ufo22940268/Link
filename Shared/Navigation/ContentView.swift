//
//  ContentView.swift
//  Link
//
//  Created by Frank Cheng on 2020/10/9.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		AppTabNavigationView()
//		#if os(iOS)
//		AppTabNavigationView()
//		#else
//		SideBarTabNavigation()
//		#endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
