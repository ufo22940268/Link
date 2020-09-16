//
//  RecordDetailMonitorView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/16.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct RecordDetailMonitorView: View {
    var item: RecordItem

    func fieldView(_ field: RecordItem.WatchField) -> some View {
        NavigationLink(destination: EmptyView()) {
            Text(field.path)
        }
    }

    var body: some View {
        List {
            if !item.failedFields.isEmpty {
                Section(header: Text("报警")) {
                    ForEach(item.failedFields) { field in
                        self.fieldView(field)
                    }
                }
            }

            if !item.okFields.isEmpty {
                Section(header: Text("正常")) {
                    ForEach(item.okFields) { field in
                        self.fieldView(field)
                    }
                }
            }
        }
    }
}

struct RecordDetailMonitorView_Previews: PreviewProvider {
    static var previews: some View {
        RecordDetailMonitorView(item: testRecordItem)
    }
}
