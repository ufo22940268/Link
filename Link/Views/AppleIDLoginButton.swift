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
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton()
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
}

struct AppleIDLoginButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("asdfasdf")
            AppleIDLoginButton()
        }
    }
}
