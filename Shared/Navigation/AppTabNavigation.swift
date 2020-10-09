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

enum OnboardType: Int {
	case dashboard
	case history
	case setting
}

struct AppTabNavigationView: View {
	@EnvironmentObject var linkData: LinkData
	@Environment(\.managedObjectContext) var context
	@State var cancellables = [AnyCancellable]()

	var dataSource: DataSource {
		DataSource(context: context)
	}

	var dashboardView: some View {
		NavigationView {
			DomainDashboardView()
		}
		.tabItem {
			Label("监控", systemImage: "cloud.fill")
		}
	}

	var historyView: some View {
		NavigationView {
			HistoryView()
		}
		.tag(OnboardType.history.rawValue)
		.tabItem {
			Label("记录", systemImage: "clock.fill")
		}
	}

	var settingView: some View {
		SettingView()
			.tabItem {
				Label("更多", systemImage: "lineweight")
			}
	}

	var body: some View {
		ZStack {
			if !linkData.isLogin {
				dashboardView
			} else {
				TabView {
					dashboardView
					historyView
					settingView
				}
			}
		}
	}
}

struct OnBoardView_Previews: PreviewProvider {
	static var previews: some View {
		LoginManager.save(loginInfo: LoginInfo(username: "aa", appleUserId: "ff"))
		let v = AppTabNavigationView()
		return v
	}
}
