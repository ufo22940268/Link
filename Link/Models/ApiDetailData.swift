//
//  ApiDetailData.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/29.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import Foundation

class ApiDetailData: ObservableObject {
    // MARK: Lifecycle

    init(api: ApiEntity) {
        self.api = api
        watchValue = api.watchValue
        watch = api.watch

        api.objectWillChange.dropFirst().debounce(for: 1, scheduler: DispatchQueue.main).flatMap { () -> AnyPublisher<Void, Never> in
            NotificationCenter.default.post(Notification(name: Notification.refreshDomain))
            if let endPoint = api.endPoint, BackendAgent().isLogin {
                return try! BackendAgent().upsert(endPoint: endPoint).replaceError(with: ()).map { _ in () }.eraseToAnyPublisher()
            } else {
                return Empty().eraseToAnyPublisher()
            }
        }.sink {}.store(in: &cancellables)
    }

    // MARK: Internal

    var api: ApiEntity

    var cancellables = [AnyCancellable]()

    @Published var watchValue: String? {
        didSet {
            api.watchValue = watchValue
        }
    }

    @Published var watch: Bool {
        didSet {
            api.watch = watch
        }
    }
}
