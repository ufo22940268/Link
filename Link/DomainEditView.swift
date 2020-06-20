//
//  DomainEditView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/20.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI


struct DomainEditView: View {
    
    @State var domainUrl: String = ""
    @State var domainName: String = ""

    var body: some View {
        Form {
            Section(header: Text("")) {
                HStack {
                    Text("域名地址")
                    Spacer()
                    TextField("example.com", text: $domainUrl, onEditingChanged: { b in
                        guard !b else { return }
                        if self.domainName == "" {
                            self.domainName = extractDomainName(fromURL: self.domainUrl)
                        }
                    }).multilineTextAlignment(.trailing).textContentType(.URL).keyboardType(.URL)
                }
                HStack {
                    Text("名字")
                    Spacer()
                    TextField("example", text: $domainName).multilineTextAlignment(.trailing)
                }
            }
        }
    }
}

struct DomainEditView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DomainEditView()
            DomainEditView().colorScheme(.dark)
        }
    }
}
