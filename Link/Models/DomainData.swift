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
    override internal init() {
        super.init()
        loginInfo = LoginManager.getLoginInfo()
        loginCancellable = $loginInfo
            .filter { $0 != nil }
            .flatMap { info in
                try! BackendAgent().login(loginInfo: info!)
            }
            .sink(receiveValue: { () in

            })
    }

    @Published var endPoints: [EndPointEntity] = []
    @Published var isLoading = false
    @Published var lastUpdateTime: Date?
    @Published var loginInfo: LoginInfo?
    var cancellables = [AnyCancellable]()
    var loginCancellable: AnyCancellable?

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
}

final class EndPointData: ObservableObject {
    @Published var endPoint: EndPointEntity

    init(endPoint: EndPointEntity) {
        self.endPoint = endPoint
    }
}
