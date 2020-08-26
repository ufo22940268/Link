//
//  JSONViewerView.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/5.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import CoreData
import SwiftUI

class JSONViewerData: ObservableObject {
    @Published var endPoint: EndPointEntity?

    init(endPoint: EndPointEntity) {
        self.endPoint = endPoint
    }
}

struct JSONViewerView: View {
    var dataSource: DataSource {
        return DataSource(context: context)
    }

    @Environment(\.managedObjectContext) var context
    @ObservedObject var modelData: JSONViewerData
    @EnvironmentObject var domainData: DomainData
    @ObservedObject var apiData: ApiEditData = ApiEditData()

    init(modelData: JSONViewerData) {
        self.modelData = modelData
        self.apiData = ApiEditData(endPoint: modelData.endPoint!)
    }

    var endPoint: EndPointEntity {
        modelData.endPoint!
    }

    @State var showingEdit = false

    var editButton: some View {
        if isValidJson {
            return AnyView(Button(action: {
                self.showingEdit = true
            }) {
                Text("编辑")
            }
            .sheet(isPresented: $showingEdit, onDismiss: { self.domainData.needReload.send() }, content: {
                EndPointEditView(type: .edit, apiEditData: self.apiData)
                    .environment(\.managedObjectContext, self.context)
            }))
        } else {
            return AnyView(EmptyView())
        }
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

    func onEditComplete() {
        modelData.objectWillChange.send()
    }

    var isValidJson: Bool {
        if let data = endPoint.data, let _ = try? JSON(data: data) {
            return true
        } else {
            return false
        }
    }

    var body: some View {
        List {
            if isValidJson {
                if errorApis.count > 0 {
                    ApiSectionView(onComplete: self.onEditComplete, apis: errorApis, title: "报警")
                }
                
                if healthyApis.count > 0 {
                    ApiSectionView(onComplete: self.onEditComplete, apis: healthyApis, title: "正常")
                }
            }

            Section(header: Text("返回结果"), footer: isValidJson ? AnyView(EmptyView()) : AnyView(Text("返回格式错误").foregroundColor(.red))) {
                JSONView(data: endPoint.data, healthy: healthyPaths, error: errorPaths)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text(lastPartOfPath), displayMode: .inline)
        .navigationBarItems(trailing: editButton)
    }
}

private struct ApiSectionView: View {
    var onComplete: () -> Void
    var apis: [ApiEntity]
    var title: String

    var body: some View {
        Section(header: Text(title)) {
            ForEach(self.apis) { api in
                NavigationLink(destination: ApiDetailView(api: Binding.constant(api), onComplete: self.onComplete), label: {
                    Text(api.paths ?? "")
                })
            }
        }
    }
}

struct JSONViewerView_Previews: PreviewProvider {
    static var validEndPointEntity: EndPointEntity {
        let j = """
        {"a": 1, "aa": 3, "d": 4, "b": "2/wefwef"}
        """
        let ee = EndPointEntity(context: context)
        ee.url = "http://biubiubiu.hopto.org:9000/link/github.json"
        ee.data = j.data(using: .utf8)

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
        return Group {
            NavigationView {
                JSONViewerView(modelData: JSONViewerData(endPoint: validEndPointEntity))
                    .environment(\.managedObjectContext, context)
            }.environment(\.colorScheme, .dark)

            NavigationView {
                JSONViewerView(modelData: JSONViewerData(endPoint: invalidEndPointEntity))
                    .environment(\.managedObjectContext, context)
            }.environment(\.colorScheme, .dark)
        }
    }
}
