//
//  JSONViewerView.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/5.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI
import SwiftyJSON

struct JSONViewerView: View {
    var json: String = ""
    @EnvironmentObject var endPoint: EndPointData

    init(json: Data?) {
        if let json = json {
            self.json = format(json)
        }
    }
    
    var editButton: some View {
        NavigationLink("编辑", destination: EndPointEditView(domain: endPoint.endPoint))
    }

    var body: some View {
        ScrollView {
            Text(json.replacingOccurrences(of: "\\", with: "")).padding()
        }
        .navigationBarTitle(Text("请求结果"), displayMode: .inline)
        .navigationBarItems(trailing: editButton)
    }

    private func format(_ value: Data) -> String {
        do {
            let json = try JSON(data: value)
            return json.rawString() ?? ""
        } catch {
            print(error)
        }
        return ""
    }
}

struct JSONViewerView_Previews: PreviewProvider {
    static var previews: some View {
        let jsonStr1 = """
        {
            "a": 3
            "b": { "c": 4 }
        }
        """
        return JSONViewerView(json: jsonStr1.data(using: .utf8)!)
    }
}
