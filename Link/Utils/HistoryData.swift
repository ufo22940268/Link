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
    @Published var timeSpan = TimeSpan.fiveMin

    var timeSpanCancellable: AnyCancellable?
    var loadSubject = PassthroughSubject<TimeSpan, Never>()

    init() {
        loadDataCancellable = loadSubject
            .flatMap { (timeSpan) -> AnyPublisher<[ScanLog]?, Never> in
                if !BackendAgent().isLogin {
                    return Empty().eraseToAnyPublisher()
                }

                let timeout = Publishers.Delay(upstream: Just<[ScanLog]?>(nil), interval: 0.5, tolerance: 0, scheduler: DispatchQueue.main)
                let load = try! BackendAgent()
                    .getScanLogs(timeSpan: timeSpan)
                    .map { items -> [ScanLog]? in
                        items
                    }
                    .replaceEmpty(with: nil)
                    .replaceError(with: nil)
                    .receive(on: DispatchQueue.main)

                return Publishers.Merge(timeout, load).eraseToAnyPublisher()
            }
            .filter { $0 != nil }
            .assign(to: \.items, on: self)

        timeSpanCancellable = $timeSpan.subscribe(loadSubject)
    }

    func loadData() {
        loadSubject.send(timeSpan)
    }
}
