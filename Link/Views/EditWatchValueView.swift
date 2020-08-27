//
//  EditWatchValueView.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/27.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct EditWatchValueView: View {
    @Binding var watchValue: String

    var body: some View {
        List {
            Section {
                TextField("", text: $watchValue)
            }
        }
        .navigationBarTitle("期望值")
    }
}

struct EditWatchValueView_Previews: PreviewProvider {
    static var previews: some View {
        EditWatchValueView(watchValue: Binding.constant("asdfasdf"))
    }
}
