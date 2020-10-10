//
//  DashboardView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/18.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import CoreData
import SwiftUI

struct DomainDashboardView: View {
	@State var showingAddEndPoint: Bool = false
	@Environment(\.managedObjectContext) var context
	@EnvironmentObject var linkData: LinkData

	var dataSource: DataSource {
		DataSource(context: context)
	}

	@ViewBuilder var refreshButton: some View {
		if linkData.endPoints.count > 0 {
			Button(action: {
				self.linkData.needReload.send()
				linkData.isLoading = true
			}) {
				#if os(iOS)
				Label(linkData.isLoading ? "刷新中" : "刷新", systemImage: "arrow.clockwise")
					.labelStyle(TitleOnlyLabelStyle())
				#else
				Label(linkData.isLoading ? "刷新中" : "刷新", systemImage: "arrow.clockwise")
				#endif
			}.disabled(linkData.isLoading)
		} else {
			EmptyView()
		}
	}

	@ViewBuilder var leadingButton: some View {
		if !BackendAgent().isLogin && linkData.endPoints.isEmpty {
			loginButton
		} else if !linkData.endPoints.isEmpty {
			refreshButton
		} else {
			EmptyView()
		}
	}

	var loginButton: some View {
		Button(action: {
			self.linkData.triggerAppleLogin()
		}) {
			Label("登录", systemImage: "person.crop.circle.fill")
				.labelStyle(TitleOnlyLabelStyle())
		}
	}

	var addButton: some View {
		Button(action: {
			self.showingAddEndPoint = true
		}, label: {
			Label("添加", systemImage: "plus")
		})
	}

	@ViewBuilder var lastUpdateView: some View {
		if let lastUpdate = linkData.lastUpdateTime {
			VStack(alignment: .leading, spacing: 8) {
				Text("更新时间: \(self.formatDate(lastUpdate))").foregroundColor(.gray)
				if !linkData.isLogin {
					HStack(spacing: 0) {
						Text("若要开启监控通知，请先").foregroundColor(.gray)
						Button("登录") {
							self.linkData.triggerAppleLogin()
						}
					}
				}
			}
			.font(.footnote)
			.padding(.leading)
			.frame(maxWidth: .infinity, alignment: .leading)
		} else {
			EmptyView()
		}
	}

	var headerView: some View {
		VStack {
			HStack(spacing: 15) {
				DomainStatisticsBlockView(status: .healthy(count: linkData.healthyCount()))
				DomainStatisticsBlockView(status: .error(count: linkData.errorCount()))
			}.padding()
			lastUpdateView
		}
	}

	var body: some View {
		Group {
			if linkData.endPoints.isEmpty {
				EmptyEndPointListView()
			} else {
				List {
					headerView
					EndPointListView()
				}
				.listStyle(GroupedListStyle())
			}
		}
		.navigationBarTitle(Text("概览"))
		.toolbar(content: {
			ToolbarItem {
				addButton
			}
			#if os(iOS)
			ToolbarItem(placement: .navigationBarLeading) {
				leadingButton
			}
			#else
			ToolbarItem {
				leadingButton
			}
			#endif
			
		})
		.sheet(isPresented: $showingAddEndPoint, onDismiss: {
			self.linkData.needReload.send()
		}, content: { () in
			EndPointEditView(type: .add)
				.environment(\.managedObjectContext, CoreDataContext.add)
		})
		.font(.body)
		.onAppear {
			CoreDataContext.edit.rollback()
		}
		.tag(OnboardType.dashboard.rawValue)
		.font(.title)
		.onAppear {
			if !DebugHelper.isPreview {
				self.linkData.needReload.send()
			}
		}
		//            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
		//                self.domainData.needReload.send()
		//            }
		.onReceive(NotificationCenter.default.publisher(for: Notification.refreshDomain), perform: { _ in
			self.linkData.needReload.send()
		})
	}

	func formatDate(_ date: Date) -> String {
		let f = DateFormatter()
		f.dateStyle = .short
		f.timeStyle = .short
		f.doesRelativeDateFormatting = true
		return f.string(from: date)
	}
}

struct DomainDashboardView_Previews: PreviewProvider {
	static var previews: some View {
		let dd = LinkData()
		dd.endPoints = try! context.fetch(EndPointEntity.fetchRequest() as NSFetchRequest<EndPointEntity>)
		return Group {
			DomainDashboardView().colorScheme(.dark)
		}
		.environment(\.managedObjectContext, context)
		.environmentObject(dd)
	}
}
