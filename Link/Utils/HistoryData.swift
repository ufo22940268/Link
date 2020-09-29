//
//  HistoryData.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/26.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import SwiftUI
import SwiftUICharts

class HistoryData: ObservableObject {
    @Published var items: [ScanLog]? = nil
    var loadDataCancellable: AnyCancellable?

    func loadData() {
        let timeout = Publishers.Delay(upstream: Just<[ScanLog]?>([ScanLog]()), interval: 0.5, tolerance: 0, scheduler: DispatchQueue.main)
        if (!BackendAgent().isLogin) {
            return
        }
        
        let load = try! BackendAgent()
            .listScanLogs()
            .map { items -> [ScanLog]? in
                items
            }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
        loadDataCancellable = Publishers.Merge(timeout, load)
            .sink { items in
                if self.items == nil || self.items!.isEmpty {
                    self.items = items
                }
            }
    }
}
