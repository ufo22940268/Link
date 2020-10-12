//
//  ApiEditListItemView.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/25.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

enum ApiListItemType {
	case view
	case edit
}

struct ApiListItemView: View {
	// MARK: Lifecycle

	init(api: Binding<ApiEntity>, showDisclosure: Bool = true, dismiss: (() -> Void)? = nil) {
		_api = api

		if showDisclosure {
			itemType = .edit
		} else {
			itemType = .view
		}

		self.dismiss = dismiss
	}

	// MARK: Internal

	@Binding var api: ApiEntity
	@State var showDetail: Bool = false
	@Environment(\.presentationMode) var presentationMode
	var dismiss: (() -> Void)?

	var body: some View {
		var view: AnyView = HStack {
			Text(api.paths ?? "")

			Spacer()

			if itemType == .edit {
				Button(action: {
					self.showDetail = true
				}, label: { () in
					Image(systemName: "info.circle")
						.foregroundColor(.accentColor)
				}).buttonStyle(BorderlessButtonStyle())
			}
		}
		.paddingMacOS()
		.contentShape(Rectangle())
		.sheet(isPresented: $showDetail, content: {
			#if os(iOS)
			NavigationView {
				ApiDetailView(api: api)
					.navigationBarItems(leading: Button("返回") {
						self.showDetail = false
					})
			}
			#else
			ApiDetailView(api: api)
				.navigationBarItems(leading: Button("返回") {
					self.showDetail = false
				})
				.alertFrame()
				.alertToolbar {
					self.showDetail = false
				}
			#endif
		}).anyView()

		if itemType == .edit {
			view = view.onTapGesture(perform: {
				self.api.watch = true
				self.api.watchValue = self.api.value
				self.dismiss?()
				NotificationCenter.default.post(Notification(name: .refreshEndPointDetail))
			})
				.anyView()
		}
		return view
	}

	// MARK: Private

	private var itemType: ApiListItemType
}

struct ApiListItemView_Previews: PreviewProvider {
	static var previews: some View {
		List {
			ForEach(TestData.apiEntities.map { api -> ApiEntity in
				api.paths = "sdfwefweoifjwoiefj.wefoiwjefoiwjef.wefowijefoij"
				return api
			}, id: \.self.paths) { api in
				ApiListItemView(api: Binding.constant(api))
			}
		}
	}
}
