//
//  ApiEditData.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/23.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

class EndPointEditData: ObservableObject {
    var cancellables = [AnyCancellable]()
    @Published var apis = [ApiEntity]()
    @Published var domainName: String = ""
    @Published var url: String = ""
    @Published var validateURLResult: ValidateURLResult = .initial
    var type: EditType!

    var originURL: String?

    var endPoint: EndPointEntity? {
        didSet {
            if let endPoint = endPoint, endPoint.url != nil {
                apis = endPoint.apis
                url = endPoint.url!
                domainName = DataSource.default.getDomainName(for: endPoint.url!)
            }
        }
    }

    var endPointId: NSManagedObjectID?
    var context: NSManagedObjectContext?

    init() {
    }

    func upsertEndPointInServer() {
        guard let endPoint = endPoint else { return }
        if BackendAgent().isLogin {
            let c = try! BackendAgent().upsert(endPoint: endPoint).sink(receiveCompletion: { _ in }, receiveValue: {})
            cancellables.append(c)
        }
    }

    func setupForCreate() {
        // Avoid setup twice
        guard endPoint == nil else { return }

        type = .add
        validateURLResult = .prompt

        let context = CoreDataContext.add
        context.rollback()
        self.context = context
        endPoint = EndPointEntity(context: context)
        endPointId = endPoint!.objectID
        domainName = ""
        url = ""

        listenToURLChange()
    }

    func setupForEdit(endPointId: NSManagedObjectID) {
        // Avoid setup twice
        guard endPoint == nil else { return }

        type = .edit
        self.endPointId = endPointId
        validateURLResult = .ok
        context = CoreDataContext.edit

        if let endPoint = try? context!.fetchOne(EndPointEntity.self, "self == %@", endPointId) {
            originURL = endPoint.url
            self.endPoint = endPoint
        }

        listenToURLChange()
    }

    var unwatchApis: [ApiEntity] {
        apis.filter { !$0.watch }
    }

    var watchApis: [ApiEntity] {
        apis.filter { $0.watch }
    }

    var responseLog: ResponseLog? {
        validateURLResult.responseLog
    }

    fileprivate func listenToURLChange() {
        guard let context = self.context else { return }
        var urlPub: AnyPublisher<String, Never> = $url.eraseToAnyPublisher()
        if type == .edit {
            urlPub = urlPub.dropFirst().eraseToAnyPublisher()
        } else {
            urlPub = urlPub.filter {
                !(self.validateURLResult == .prompt && $0 == "")
            }.eraseToAnyPublisher()
        }

        let dbDataSource = DataSource(context: context)
        urlPub
            .filter { url in
                self.validateURLResult = .pending
                if (self.type == .add && dbDataSource.isURLExists(url))
                    || (self.type == .edit && url != self.originURL && dbDataSource.isURLExists(url)) {
                    self.validateURLResult = ValidateURLResult.duplicatedUrl
                    self.apis = []
                    return false
                }

                if !url.isValidURL() {
                    self.apis = []
                    self.validateURLResult = .formatError
                    return false
                }

                return true
            }
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .flatMap { url -> AnyPublisher<ValidateURLResult, Never> in
                ApiHelper(context: context).test(url: url).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .flatMap { result -> AnyPublisher<[ApiEntity], Never> in
                self.validateURLResult = result
                if case .ok = result {
                    return ApiHelper(context: self.context!)
                        .fetchAndUpdateEntity(endPoint: self.endPoint!)
                        .catch { _ in Just([]) }
                        .eraseToAnyPublisher()
                } else {
                    return Just([]).eraseToAnyPublisher()
                }
            }
            .sink { apis in
                self.apis = apis
            }
            .store(in: &cancellables)
    }
}
