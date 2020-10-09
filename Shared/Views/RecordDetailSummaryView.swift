//
//  RecordDetailSummaryView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/11.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct RecordDetailSummaryView: View {
    var item: RecordItem

    var body: some View {
        Section {
            InfoRow(label: "日期", value: item.time.formatFullDate)
            InfoRow(label: "状态码", value: item.statusCode)
            InfoRow(label: "时长", value: item.duration.formatDuration)
        }
    }
}

struct RecordDetailSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        return RecordDetailSummaryView(item: testRecordItem).colorScheme(.dark)
    }
}
