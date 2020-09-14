//
//  JSONWrapper.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/13.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation

struct JSONFragment {
    var text: String
    var hightlight = false
}

extension JSON {
    func getJSONFragments(highlight paths: [String]) -> [JSONFragment] {
        [JSONFragment(text: "a"), JSONFragment(text: "b", hightlight: true)]
    }
    
    var result: JSON {
        return self["result"]
    }
}
