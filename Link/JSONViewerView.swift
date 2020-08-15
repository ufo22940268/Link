//
//  JSONViewerView.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/5.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import CoreData
import SwiftUI

struct JSONViewerView: View {
    @EnvironmentObject var domainData: DomainData
    @EnvironmentObject var dataSource: DataSource
    @Environment(\.endPointId) var endPointId: NSManagedObjectID?
    @Environment(\.managedObjectContext) var context

    var endPoint: EndPointEntity {
        domainData.findEndPointEntity(by: endPointId!)!
    }

    @State var showingEdit = false
    let apiEditData = ApiEditData()

    var editButton: some View {
        Button(action: {
            self.showingEdit = true
        }) {
            Text("编辑")
        }.sheet(isPresented: $showingEdit, content: {
            EndPointEditView(endPointId: self.endPoint.objectID,
                             apiEditData: self.apiEditData)
                .environment(\.managedObjectContext, self.context)
                .environmentObject(self.dataSource)
                .environmentObject(self.domainData)
        })
    }

    var highlightPaths: [String] {
        if let apis = endPoint.api?.allObjects as? [ApiEntity] {
            return apis.filter { $0.watch && $0.paths != nil } .map { $0.paths! }
        }
        return []
    }

    var body: some View {
        ScrollView {
            JSONView(data: endPoint.data, healthy: highlightPaths).padding()
        }
        .navigationBarTitle(Text("请求结果"), displayMode: .inline)
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
        return JSONViewerView().environmentObject(EndPointData(endPoint: ee))
    }
}
