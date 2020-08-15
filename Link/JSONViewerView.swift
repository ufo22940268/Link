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
    @EnvironmentObject var dataSource: DataSource
    @Environment(\.endPointId) var endPointId: NSManagedObjectID?
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
        }.sheet(isPresented: $showingEdit, content: {
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

    var body: some View {
        VStack {
            ScrollView {
                JSONView(data: endPoint.data, healthy: healthyPaths, error: errorPaths).padding()
            }
        }
        .navigationBarTitle(Text(lastPartOfPath))
        .navigationBarItems(trailing: editButton)
    }
}

struct JSONViewerView_Previews: PreviewProvider {
    static var previews: some View {
        _ = """
        {
            "a": 3
            "b": { "c": 4 }
        }
        """
        let ee = EndPointEntity()
        let ae = ApiEntity()
        ae.paths = "b.c"
        ee.api?.adding(ae)
//        return JSONViewerView().environmentObject(EndPointData(endPoint: ee))
        return EmptyView()
    }
}
