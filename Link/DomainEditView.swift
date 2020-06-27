//
//  DomainEditView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/20.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

extension String {
    
    func isValidURL() -> Bool {
        guard !contains("..") else { return false }
        
        let head = "((http|https)://)?([(w|W)]{3}+\\.)?"
        let tail = "\\.+[A-Za-z]{2,3}+(\\.)?+(/(.)*)?"
        let urlRegEx = head+"+(.)+"+tail
        
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        return urlTest.evaluate(with: trimmingCharacters(in: .whitespaces))
    }
}

struct DomainEditView: View {
    
    @State var domainUrl: String = ""
    @State var domainName: String = ""
    
    var nextButton: some View {
        Button(action: {
        }) {
            Text("下一步")
        }.disabled(!isFormValid)
    }
    
    var isFormValid: Bool {
        return domainUrl.isValidURL()
    }
    
    var body: some View {
        Form {
            Section(header: Text("")) {
                HStack {
                    Text("域名地址")
                    Spacer()
                    TextField("https://example.com", text: $domainUrl, onEditingChanged: { b in
                        guard !b else { return }
                        if self.domainName == "" {
                            self.domainName = extractDomainName(fromURL: self.domainUrl)
                        }
                    }).multilineTextAlignment(.trailing).textContentType(.URL).keyboardType(.URL).autocapitalization(.none)
                }
                HStack {
                    Text("名字")
                    Spacer()
                    TextField("example", text: $domainName).multilineTextAlignment(.trailing)
                }
            }
        }
        .navigationBarTitle("输入域名", displayMode: .inline)
        .navigationBarItems(trailing: nextButton)
    }
}

struct DomainEditView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                DomainEditView()
            }
            NavigationView {
                DomainEditView()
            }.colorScheme(.dark)
        }
    }
}
