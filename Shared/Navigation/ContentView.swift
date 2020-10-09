//
//  ContentView.swift
//  Link
//
//  Created by Frank Cheng on 2020/10/9.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct ContentView: View {
	
	@StateObject var linkData = LinkData()
	
    var body: some View {
		#if os(iOS)
		AppTabNavigationView()
			.environmentObject(linkData)
		#else
		SideBarTabNavigation()
			.environmentObject(linkData)
		#endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
