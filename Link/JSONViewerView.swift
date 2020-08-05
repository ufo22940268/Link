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
    
    init(json: Data?) {
        if let json = json {
            self.json = self.format(json)
        }
    }
    
    var body: some View {
        ScrollView {
            Text(json).padding()
        }.navigationBarTitle(Text("请求结果"), displayMode: .inline)
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
