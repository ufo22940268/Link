//
//  JSONViewerView.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/5.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import CoreData
import SwiftUI
import SwiftyJSON

struct JSONViewerView: View {
    var jsons: [(String, Bool)] {
        format(endPoint.data)
    }

    @EnvironmentObject var domainData: DomainData
    @Environment(\.endPointId) var endPointId: NSManagedObjectID?
    @Environment(\.managedObjectContext) var context
    var endPoint: EndPointEntity {
        domainData.findEndPointEntity(by: endPointId!)!
    }

    @State var showingEdit = false

    var editButton: some View {
        Button(action: {
            self.showingEdit.toggle()
        }) {
            Text("编辑")
        }
    }

    var body: some View {
        ScrollView {
            ZStack {
                jsons.reduce(Text(""), { accu, t in accu + Text(t.0).foregroundColor(t.1 ? Color.accentColor : nil) })
            }.padding()
        }
        .navigationBarTitle(Text("请求结果"), displayMode: .inline)
        .navigationBarItems(trailing: editButton)
        .sheet(isPresented: $showingEdit, content: {
            NavigationView {
                EndPointEditView()
                    .environment(\.endPointId, self.endPoint.objectID)
                    .environment(\.managedObjectContext, self.context)
                    .environmentObject(self.domainData)
            }
        })
    }

    private func removeSlash(_ str: String) -> String {
        str.replacingOccurrences(of: "\\", with: "")
    }

    private func format(_ value: Data?) -> [(String, Bool)] {
        guard let value = value else { return [] }

        var r = [(String, Bool)]()
        do {
            let json = try JSON(data: value)
            let rawString = json.rawString() ?? ""

            // TODO: Find highlight key by search with regex. It may cause the wrong string fields to be hightlighted.
            if let api = endPoint.api?.anyObject() as? ApiEntity, let paths = api.paths {
                let re = try? NSRegularExpression(pattern: "(?<be>.+)(?<mi>\"\(paths)\")(?<af>.+)?", options: [.dotMatchesLineSeparators])
                if let m = re?.firstMatch(in: rawString, options: [], range: NSRange(location: 0, length: rawString.count)), m.numberOfRanges >= 3 {
                    r.append((removeSlash(rawString[m.range(withName: "be")]), false))
                    r.append((removeSlash(rawString[m.range(withName: "mi")]), true))

                    if m.range(withName: "af").location != NSNotFound {
                        r.append((removeSlash(rawString[m.range(withName: "af")]), false))
                    }
                }
            }
        } catch {
            print(error)
        }
        return r
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
