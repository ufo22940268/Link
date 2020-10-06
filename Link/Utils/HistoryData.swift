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

fileprivate let TIME_SPAN_KEY = "TIME_SPAN"

class HistoryData: LoadableObject<ScanLog> {
    var loadDataCancellable: AnyCancellable?
    @Published var timeSpan = HistoryData.readTimeSpan()

    var timeSpanCancellable: AnyCancellable?
    var loadSubject = PassthroughSubject<TimeSpan, Never>()

    override init() {
        super.init()
        loadDataCancellable = loadSubject
            .removeDuplicates()
            .flatMap { (timeSpan) -> AnyPublisher<[ScanLog], ResponseError> in
                self.loadState = .loading
                if !BackendAgent().isLogin {
                    return Fail(outputType: [ScanLog].self, failure: ResponseError.notLogin).eraseToAnyPublisher()
                }

//                let timeout = Publishers.Delay(upstream: Just<[ScanLog]>([ScanLog]()), interval: 0.5, tolerance: 0, scheduler: DispatchQueue.main)
//                    .setFailureType(to: ResponseError.self)
                let load = try! BackendAgent()
                    .getScanLogs(timeSpan: timeSpan)
                    .receive(on: DispatchQueue.main)

                return load.eraseToAnyPublisher()
            }
			.delay(for: 3, scheduler: DispatchQueue.main)
            .subscribe(updateStateSubject)

        timeSpanCancellable = $timeSpan
            .map { ts in
                self.save(timeSpan: ts)
                return ts
            }
            .subscribe(loadSubject)
    }

    static func readTimeSpan() -> TimeSpan {
        TimeSpan.parse(UserDefaults.standard.double(forKey: TIME_SPAN_KEY))
    }

    func save(timeSpan: TimeSpan) {
        UserDefaults.standard.set(timeSpan.rawValue, forKey: TIME_SPAN_KEY)
    }

    func loadData() {
        loadSubject.send(timeSpan)
    }
}
