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

final class LinkData: NSObject, ObservableObject {
    @Published var endPoints: [EndPointEntity] = []
    @Published var isLoading = false
    @Published var loginInfo: LoginInfo?
    var cancellables = [AnyCancellable]()
    var loginCancellable: AnyCancellable?
    var reloadCancellable: AnyCancellable?
    var syncCancellable: AnyCancellable?
    var context: NSManagedObjectContext = CoreDataContext.main
    var dataSource = DataSource()
    var needReload = PassthroughSubject<Void, Never>()

    var lastUpdateTime: Date? {
        DataSource(context: CoreDataContext.main).getLastUpdatedTime()
    }

    override internal init() {
        super.init()

        loginInfo = LoginManager.getLoginInfo()
        loginCancellable = $loginInfo
            .filter { $0 != nil }
            .setFailureType(to: ResponseError.self)
            .flatMap { info in
                try! BackendAgent().login(loginInfo: info!)
            }
            .flatMap { () -> AnyPublisher<Void, ResponseError> in
                if let endPoints = self.dataSource.fetchEndPoints() {
                    return BackendAgent()
                        .sync(endPoints: endPoints)
                        .eraseToAnyPublisher()
                } else {
                    return Empty().eraseToAnyPublisher()
                }
            }
            .flatMap { () -> AnyPublisher<Void, ResponseError> in
                BackendAgent().syncFromServer(context: CoreDataContext.main)
            }
            .flatMap { () in
                BackendAgent()
                    .runScanLogTask()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: {
                self.needReload.send()
                NotificationCenter.default.post(Notification(name: Notification.reloadHistory))
            })

        reloadCancellable = Publishers.Concatenate(prefix: needReload.first(), suffix: needReload.debounce(for: 0.5, scheduler: DispatchQueue.main))
            .receive(on: DispatchQueue.main)
            .flatMap { (_) -> AnyPublisher<Void, Never> in
                print("loadDomains \(Date())")
                let context = CoreDataContext.main
                let req: NSFetchRequest<EndPointEntity> = EndPointEntity.fetchRequest()
                if let domains = try? context.fetch(req).filter({ $0.url != nil }) {
                    self.endPoints = domains
                } else {
                    self.endPoints = []
                }

                self.isLoading = false
                guard !self.endPoints.isEmpty else { return Empty().eraseToAnyPublisher() }
                return HealthChecker(domains: self.endPoints, context: CoreDataContext.main)
                    .checkHealth()
                    .receive(on: DispatchQueue.main)
                    .map { _ in
                        DataSource().updateLastTime()
                        self.objectWillChange.send()
                        self.isLoading = false
                    }
                    .replaceError(with: ())
                    .eraseToAnyPublisher()
            }.sink { }
    }

    func logout() {
        LoginManager.logout()
        loginInfo = nil
    }

    func healthyCount() -> Int {
        endPoints.filter { $0.status == HealthStatus.healthy }.count
    }

    func errorCount() -> Int {
        endPoints.filter { $0.status == HealthStatus.error }.count
    }

    func findEndPointEntity(by id: NSManagedObjectID) -> EndPointEntity? {
        endPoints.first { $0.objectID == id }
    }

    static func test(context: NSManagedObjectContext) -> LinkData {
        let req: NSFetchRequest<EndPointEntity> = EndPointEntity.fetchRequest()
        req.predicate = NSPredicate(format: "url == %@", "http://biubiubiu.hopto.org:9000/link/github.json")
        let dd = LinkData()
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

extension LinkData: ASAuthorizationControllerDelegate {
    var isLogin: Bool {
        loginInfo != nil
    }

    @objc
    func triggerAppleLogin() {
        if !MyDevice.isSimulator {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName]

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        } else {
            postLogin("simulator_name", "simulator_device_token")
        }
    }

    fileprivate func postLogin(_ username: String, _ userId: String) {
        let loginInfo = LoginInfo(username: username, appleUserId: userId)
        LoginManager.save(loginInfo: loginInfo)
        self.loginInfo = loginInfo
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credential as ASAuthorizationAppleIDCredential:
            let username = credential.fullName?.givenName ?? ""
            let userId = credential.user
            postLogin(username, userId)
        default:
            break
        }
    }
}
