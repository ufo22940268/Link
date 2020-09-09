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

    var api: ApiEntity

    var cancellables = [AnyCancellable]()

    init(api: ApiEntity) {
        self.api = api
        watchValue = api.watchValue
        watch = api.watch

        api.objectWillChange.dropFirst().debounce(for: 1, scheduler: DispatchQueue.main).flatMap { () -> AnyPublisher<Void, Never> in
            if let endPoint = api.endPoint {
                return try! BackendAgent().upsert(endPoint: endPoint).replaceError(with: ()).map({ _ in () }).eraseToAnyPublisher()
            } else {
                return Empty().eraseToAnyPublisher()
            }
        }.sink {}.store(in: &cancellables)
    }
}
