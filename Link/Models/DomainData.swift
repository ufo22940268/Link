//
//  DomainData.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/3.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import AuthenticationServices
import Combine
import CoreData
import SwiftUI

final class DomainData: NSObject, ObservableObject {
    @Published var endPoints: [EndPointEntity] = []
    @Published var isLoading = false
    @Published var lastUpdateTime: Date?
    @Published var loginInfo: LoginInfo?
    var cancellables = [AnyCancellable]()
    var loginCancellable: AnyCancellable?
    var reloadCancellable: AnyCancellable?
    var syncCancellable: AnyCancellable?

    override internal init() {
        super.init()
        loginInfo = LoginManager.getLoginInfo()
        loginCancellable = $loginInfo
            .filter { $0 != nil }
            .dropFirst()
            .setFailureType(to: ResponseError.self)
            .flatMap { info in
                try! BackendAgent().login(loginInfo: info!)
            }
            .flatMap { () -> AnyPublisher<Void, ResponseError> in
                if let endPoints = DataSource().fetchEndPoints() {
                    return BackendAgent()
                        .sync(endPoints: endPoints)
                        .eraseToAnyPublisher()
                } else {
                    return Empty().eraseToAnyPublisher()
                }
            }
            .flatMap { () in
                BackendAgent()
                    .runScanLogTask()
            }
            .sink(receiveCompletion: { _ in
            }, receiveValue: {
                print("send reload history--------")
                NotificationCenter.default.post(Notification(name: Notification.reloadHistory))
            })

        reloadCancellable = needReload.flatMap { (_) -> AnyPublisher<Void, Never> in
            print("loadDomains")
            let context = CoreDataContext.main
            let req: NSFetchRequest<EndPointEntity> = EndPointEntity.fetchRequest()
            if let domains = try? context.fetch(req).filter({ $0.url != nil }) {
                self.endPoints = domains
            } else {
                self.endPoints = []
            }

            self.isLoading = true
            guard !self.endPoints.isEmpty else { return Empty().eraseToAnyPublisher() }
            return HealthChecker(domains: self.endPoints, context: CoreDataContext.main)
                .checkHealth()
                .receive(on: DispatchQueue.main)
                .map { _ in
                    self.lastUpdateTime = Date()
                    self.objectWillChange.send()
                    self.isLoading = false
                }
                .replaceError(with: ())
                .eraseToAnyPublisher()
        }.sink { }
    }

    var needReload = PassthroughSubject<Void, Never>()

    func healthyCount() -> Int {
        endPoints.filter { $0.status == HealthStatus.healthy }.count
    }

    func errorCount() -> Int {
        endPoints.filter { $0.status == HealthStatus.error }.count
    }

    func findEndPointEntity(by id: NSManagedObjectID) -> EndPointEntity? {
        endPoints.first { $0.objectID == id }
    }

    static func test(context: NSManagedObjectContext) -> DomainData {
        let req: NSFetchRequest<EndPointEntity> = EndPointEntity.fetchRequest()
        req.predicate = NSPredicate(format: "url == %@", "http://biubiubiu.hopto.org:9000/link/github.json")
        let dd = DomainData()
        dd.endPoints = try! context.fetch(req)
        return dd
    }

    func deleteEndPoint(by url: String) {
        let agent = BackendAgent()
        try? agent.deleteEndPoint(by: url)
            .sink(receiveCompletion: { _ in }, receiveValue: {})
            .store(in: &cancellables)
    }
}

extension DomainData: ASAuthorizationControllerDelegate {
    var isLogin: Bool {
        loginInfo != nil
    }

    @objc
    func triggerAppleLogin() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credential as ASAuthorizationAppleIDCredential:
            let username = credential.fullName?.givenName ?? ""
            let userId = credential.user
            let loginInfo = LoginInfo(username: username, appleUserId: userId)
            LoginManager.save(loginInfo: loginInfo)
            self.loginInfo = loginInfo
        default:
            break
        }
    }

    func postLogin() {
        if let endPoints = DataSource().fetchEndPoints() {
            syncCancellable = BackendAgent()
                .sync(endPoints: endPoints)
                .sink(receiveCompletion: { _ in
                }, receiveValue: {
                })
        }
    }
}
