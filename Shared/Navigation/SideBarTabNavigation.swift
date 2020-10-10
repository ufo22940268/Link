//
//  SideBarTabNavigation.swift
//  Link
//
//  Created by Frank Cheng on 2020/10/9.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct SideBarTabNavigation: View {
	@State var selection: Set<OnboardType> = [OnboardType.dashboard]

	var settingButton: some View {
		VStack(alignment: .leading, spacing: 0) {
			Divider()
			Button(action: {}) {
				Label("更多", systemImage: "lineweight")
			}
			.padding(.vertical, 8)
			.padding(.horizontal, 16)
			.buttonStyle(PlainButtonStyle())
		}
	}

	var body: some View {
		NavigationView {
			List(selection: $selection) {
				NavigationLink(
					destination: DomainDashboardView(),
					label: {
						Label("监控", systemImage: "cloud.fill")
					})
					.tag(OnboardType.dashboard)
				NavigationLink(
					destination: HistoryView(),
					label: {
						Label("记录", systemImage: "clock.fill")
					})
					.tag(OnboardType.history)
			}
			.overlay(settingButton, alignment: .bottom)
			.listStyle(SidebarListStyle())

			Text("Select a menu")
			Text("Select a item")
		}
	}
}

struct SideBarTabNavigation_Previews: PreviewProvider {
	static var previews: some View {
		SideBarTabNavigation()
	}
}
