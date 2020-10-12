//
//  EndPointEditView.swift
//  Link
//
//  Created by Frank Cheng on 2020/7/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

enum Segment: Int, RawRepresentable, CaseIterable {
	case all = 0
	case watch = 1

	// MARK: Internal

	var label: String {
		switch self {
		case .all:
			return "全部"
		case .watch:
			return "已关注"
		}
	}
}

struct ApiListView: View {
	// MARK: Lifecycle

	init(apis: [ApiEntity]) {
		self.apis = apis
	}

	// MARK: Internal

	@Environment(\.managedObjectContext) var context
	@State var segment = Segment.all.rawValue
	@Environment(\.presentationMode) var presentationMode
	var apis: [ApiEntity]

	var unwatchApis: [ApiEntity] {
		return apis.filter { !$0.watch }
	}

	var body: some View {
		print("refresh")
		return ZStack {
			List(unwatchApis, id: \.self) { api in
				ApiListItemView(api: self.getApiBinding(api), dismiss: {
					self.presentationMode.wrappedValue.dismiss()
				})
			}
		}
		navigationBarTitle("添加字段")
	}

	func buildApiSelection() -> Binding<Set<ApiEntity>> {
		Binding<Set<ApiEntity>>(get: { () -> Set<ApiEntity> in
			Set<ApiEntity>(self.apis.filter { $0.watch })
		}) { apis in
			self.apis.forEach { api in
				api.watch = apis.contains(api)
			}
		}
	}

	func getApiBinding(_ api: ApiEntity) -> Binding<ApiEntity> {
		let index = apis.firstIndex(of: api)!
		return Binding.constant(apis[index])
	}

	// MARK: Private

	private var cancellables = [AnyCancellable]()
}

struct ApiListView_Previews: PreviewProvider {
	static var previews: some View {
		let a = ApiEntity(context: context)
		a.paths = "aa.bnb.cc.wefwef"
		a.value = "CoreData: error: Failed to call designated initializer on NSManagedObject class 'Link.EndPointEntity' CoreData: error: Failed to call designated initializer on NSManagedObject class 'Link.EndPointEntity'"
		a.watch = true
		let a2 = ApiEntity(context: context)
		a2.paths = "wefwef2.wef"
		a2.value = "12322"
		a2.watch = false
		return NavigationView {
			ApiListView(apis: [a, a2])
				.environment(\.managedObjectContext, context)
				.colorScheme(.light)
		}
	}
}
