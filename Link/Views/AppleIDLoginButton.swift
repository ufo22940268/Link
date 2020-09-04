//
//  AppleIdLoginButton.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import AuthenticationServices
import SwiftUI

struct AppleIDLoginButton: UIViewRepresentable {
    
    @Environment(\.colorScheme) var colorScheme
    
    func makeCoordinator() -> Coordinate {
        return Coordinate()
    }

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: colorScheme == ColorScheme.dark ? .white : .black)
        button.addTarget(context.coordinator, action: #selector(Coordinate.handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}

    class Coordinate: NSObject, ASAuthorizationControllerDelegate {
        @objc
        func handleAuthorizationAppleIDButtonPress() {
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
                LoginStore.save(loginInfo: LoginInfo(username: username, appleUserId: userId))
            default:
                break
            }
        }
    }
}

struct AppleIDLoginButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                Text("asdfasdf")
                AppleIDLoginButton()
                    .frame(height: 45)
            }
            .padding()
            .colorScheme(.dark)

            VStack {
                Text("asdfasdf")
                AppleIDLoginButton()
                    .frame(height: 45)
            }
            .padding()
            .colorScheme(.dark)
        }
    }
}
