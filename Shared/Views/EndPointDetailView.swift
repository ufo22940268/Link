//
//  JSONViewerView.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/5.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

struct EndPointDetailView: View {
	// MARK: Lifecycle

	init(endPoint: EndPointEntity, context: NSManagedObjectContext? = nil) {
		self.endPoint = endPoint
	}

	// MARK: Internal

	enum Segment: Int, RawRepresentable, CaseIterable {
		case response = 0
		case metric = 1

		// MARK: Internal

		var label: String {
			switch self {
			case .response:
				return "请求返回"
			case .metric:
				return "其他信息"
			}
		}
	}

	@Environment(\.managedObjectContext) var context
	@ObservedObject var endPoint: EndPointEntity
	@EnvironmentObject var domainData: LinkData
	@State var segment = Segment.response.rawValue
	var endPointCancellable: AnyCancellable?
	@State var cancellables = [AnyCancellable]()

	@State var showingEdit = false

	var dataSource: DataSource {
		DataSource(context: context)
	}

	var editButton: some View {
		AnyView(Button(action: {
			self.showingEdit = true
		}) {
			Text("编辑")
		})
	}

	var lastPartOfPath: String {
		if let r = endPoint.endPointPath.range(of: #"(?<=/).+?$"#, options: .regularExpression) {
			return String(endPoint.endPointPath[r])
		}

		return ""
	}

	var healthyPaths: [String] {
		if let apis = endPoint.api?.allObjects as? [ApiEntity] {
			return apis.filter { $0.watch && $0.healthyStatus == .healthy }.map { $0.paths! }
		}
		return []
	}

	var errorPaths: [String] {
		if let apis = endPoint.api?.allObjects as? [ApiEntity] {
			return apis.filter { $0.watch && $0.healthyStatus == .error }.map { $0.paths! }
		}
		return []
	}

	var errorApis: [ApiEntity] {
		endPoint.apis.filter { $0.watch && !$0.match }
	}

	var healthyApis: [ApiEntity] {
		endPoint.apis.filter { $0.watch && $0.match }
	}

	var isValidJson: Bool {
		if let data = endPoint.data, let _ = try? JSON(data: data) {
			return true
		} else {
			return false
		}
	}

	var responseSectionView: some View {
		Group {
			if isValidJson {
				if errorApis.count > 0 {
					ApiSectionView(onComplete: self.onEditComplete, apis: errorApis, title: "报警")
				}

				if healthyApis.count > 0 {
					ApiSectionView(onComplete: self.onEditComplete, apis: healthyApis, title: "正常")
				}
			}

			Section(header: Text("返回结果"), footer: isValidJson ? AnyView(EmptyView()) : AnyView(Text("返回格式错误"))) {
				JSONView(data: endPoint.data, healthy: healthyPaths, error: errorPaths)
					.frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
			}
		}
	}

	var metricSectionView: some View {
		Group {
			Section(header: Text("")) {
				InfoRow(label: "响应时间", value: endPoint.duration.formatDuration)
				InfoRow(label: "状态码", value: endPoint.statusCode)
			}
		}
	}

	var historySectionView: some View {
		EmptyView()
	}

	var pickerView: some View {
		ZStack(alignment: .center, content: {
			Picker("Select category", selection: $segment) {
				ForEach(Segment.allCases, id: \.self.rawValue) { segment in
					Text(segment.label).tag(segment.rawValue)
				}
			}
			.labelsHidden()
			.pickerStyle(SegmentedPickerStyle())
			.fixedSize()
			.padding()
		})
			.frame(maxWidth: .infinity)
	}

	var body: some View {
		List {
			#if os(iOS)
			Section(header: pickerView) {
				EmptyView()
			}
			#else
			pickerView
			#endif

			if segment == Segment.response.rawValue {
				responseSectionView
			} else if segment == Segment.metric.rawValue {
				metricSectionView
			}
		}
		.sheet(isPresented: $showingEdit, onDismiss: {
			self.domainData.needReload.send()
		}, content: { () in
			EndPointEditView(type: .edit, endPoint: endPoint.objectID)
				.environment(\.managedObjectContext, CoreDataContext.edit)
		})
		.listStyle(GroupedListStyle())
		//        .navigationBarTitle(Text(lastPartOfPath), displayMode: .inline)
		.navigationBarTitle(Text(lastPartOfPath))
		.navigationBarItems(trailing: editButton)
		.onReceive(NotificationCenter.default.publisher(for: Notification.Name.updateEndPointDetail), perform: { _ in
			self.refresh()
		})
	}

	func onEditComplete() {
		try! CoreDataContext.edit.save()
		try! CoreDataContext.main.save()
		endPoint.objectWillChange.send()
		domainData.needReload.send()
	}

	// MARK: Private

	private func refresh() {
		endPoint.objectWillChange.send()
	}
}

struct EndPointDetailView_Previews: PreviewProvider {
	static var validEndPointEntity: EndPointEntity {
		let j = """
		{"a": 1, "aa": 3, "d": 4, "b": "2/wefwef"}
		"""
		let ee = EndPointEntity(context: context)
		ee.url = "http://biubiubiu.hopto.org:9000/link/github.json"
		ee.data = j.data(using: .utf8)
		ee.duration = 0.13
		ee.statusCode = 200

		let ae = ApiEntity(context: context)
		ae.paths = "aa"
		ae.value = "3"
		ae.watch = true
		ae.watchValue = "4"
		ae.endPoint = ee

		let ae2 = ApiEntity(context: context)
		ae2.paths = "d"
		ae2.value = "4"
		ae2.watch = true
		ae2.watchValue = "4"
		ae2.endPoint = ee

		ee.api = NSSet(array: [ae, ae2])
		return ee
	}

	static var invalidEndPointEntity: EndPointEntity {
		let j = """
		    <body>error</body>
		"""
		let ee = EndPointEntity(context: context)
		ee.url = "http://biubiubiu.hopto.org:9000/link/github.json2"
		ee.data = j.data(using: .utf8)

		let ae = ApiEntity(context: context)
		ae.paths = "aaasdf"
		ae.value = "3"
		ae.watch = true
		ae.watchValue = "4"
		ae.endPoint = ee

		let ae2 = ApiEntity(context: context)
		ae2.paths = "d2"
		ae2.value = "4"
		ae2.watch = true
		ae2.watchValue = "4"
		ae2.endPoint = ee

		ee.api = NSSet(array: [ae, ae2])
		return ee
	}

	static var previews: some View {
		Group {
			EndPointDetailView(endPoint: validEndPointEntity)
				.environment(\.managedObjectContext, context)
		}
	}
}
