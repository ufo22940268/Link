//
//  Loadable.swift
//  Link
//
//  Created by Frank Cheng on 2020/10/6.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import Foundation

enum LoadableState {
    case pending
    case loading
    case finished
    case error(_ error: Error)
}

class LoadableObject<Item>: ObservableObject {
    @Published var loadState: LoadableState = .pending
    @Published var items: [Item] = [Item]()

    var stateCancellable: AnyCancellable?

    var updateStateSubject: PassthroughSubject<[Item], ResponseError> {
        let subject = PassthroughSubject<[Item], ResponseError>()
        stateCancellable = subject.print().sink(receiveCompletion: { complete in
            switch complete {
            case let .failure(error):
                self.loadState = .error(error)
            case .finished:
                break
            }
        }, receiveValue: {
            self.loadState = .finished
            self.items = $0
        })
        return subject
    }
}
