//
//  HIstoryView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct HistoryView: View {
    
    var emptyView: some View {
        HistoryEmptyView()
    }
    
    var body: some View {
       emptyView
    }
}

struct HIstoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
