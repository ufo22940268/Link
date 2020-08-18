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
    @Published var endPoint: EndPointEntity = EndPointEntity()

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

    var endPoint: EndPointEntity {
        modelData.endPoint
    }

    @State var showingEdit = false

    var editButton: some View {
        Button(action: {
            self.showingEdit = true
        }) {
            Text("编辑")
        }
        .sheet(isPresented: $showingEdit, content: {
            EndPointEditView(endPointId: self.endPoint.objectID)
                .environment(\.managedObjectContext, self.context)
                .environmentObject(self.dataSource)
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
            return apis.filter { $0.watch && $0.healthyStatus! == .healthy }.map { $0.paths! }
        }
        return []
    }

    var errorPaths: [String] {
        if let apis = endPoint.api?.allObjects as? [ApiEntity] {
            return apis.filter { $0.watch && $0.healthyStatus! == .error }.map { $0.paths! }
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

    var body: some View {
        List {
            if errorApis.count > 0 {
                ApiSection(onComplete: self.onEditComplete, apis: errorApis, title: "报警")
            }

            if healthyApis.count > 0 {
                ApiSection(onComplete: self.onEditComplete, apis: healthyApis, title: "正常")
            }

            Section(header: Text("返回结果")) {
                ScrollView {
                    JSONView(data: endPoint.data, healthy: healthyPaths, error: errorPaths)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text(lastPartOfPath))
        .navigationBarItems(trailing: editButton)
    }
}

struct JSONViewerView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
        return NavigationView {
            JSONViewerView(modelData: JSONViewerData(endPoint: ee))
                .environment(\.managedObjectContext, context)
        }.environment(\.colorScheme, .dark)
    }
}

private struct ApiSection: View {
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
