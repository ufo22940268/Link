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
    case empty
    case finished
    case error(_ error: Error)
}

class LoadableObject<Item>: ObservableObject {
    @Published var loadState: LoadableState = .loading
    @Published var item: Item? = nil

    var stateCancellable: AnyCancellable?

    var updateStateSubject: PassthroughSubject<Item, ResponseError> {
        let subject = PassthroughSubject<Item, ResponseError>()
        stateCancellable = subject.sink(receiveCompletion: { complete in
            switch complete {
            case let .failure(error):
                self.loadState = .error(error)
            case .finished:
                break
            }
        }, receiveValue: {
            self.item = $0
            self.loadState = .finished
        })
        return subject
    }
}

class LoadableObjects<Item>: ObservableObject {
    @Published var loadState: LoadableState = .loading
    @Published var items: [Item] = [Item]()

    var stateCancellable: AnyCancellable?

    var updateStateSubject: PassthroughSubject<[Item], ResponseError> {
        let subject = PassthroughSubject<[Item], ResponseError>()
        stateCancellable = subject.sink(receiveCompletion: { complete in
            switch complete {
            case let .failure(error):
                self.loadState = .error(error)
            case .finished:
                break
            }
        }, receiveValue: {
            self.items = $0
            if $0.isEmpty {
                self.loadState = .empty
            } else {
                self.loadState = .finished
            }
        })
        return subject
    }
}
