//
//  EndPointEditView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/20.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import CoreData
import SwiftUI

extension String {
    func isValidURL() -> Bool {
        let urlRegEx = "^https?://.+$"
        let urlTest = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: self)
        return result
    }
}

struct EndPointEditView: View {
    @Environment(\.managedObjectContext) var context
    @State var endPointUrl: String = ""
    @State var domainName: String = ""
    @FetchRequest(entity: EndPointEntity.entity(), sortDescriptors: []) var endPoints: FetchedResults<EndPointEntity>
    @EnvironmentObject var domainData: DomainData

    var nextButton: some View {
        Button(action: {
            var endPoint: EndPointEntity
            if let nd = self.endPoints.first(where: { $0.url == self.endPointUrl }) {
                endPoint = nd
            } else {
                endPoint = EndPointEntity(context: self.context)
                endPoint.url = self.endPointUrl
                let domain = DomainEntity(context: self.context)
                domain.name = self.domainName
                endPoint.domain = domain
            }

            do {
                try self.context.save()
            } catch let error as NSError {
                print("Error: \(error), \(error.userInfo)")
            }
            
            self.domainData.onAddedDomain.send()
        }) {
            Text("下一步")
        }.disabled(!isFormValid)
    }

    var isFormValid: Bool {
        return endPointUrl.isValidURL()
    }

    var body: some View {
        Form {
            Section(header: Text("")) {
                HStack {
                    Text("域名地址")
                    Spacer()
                    TextField("https://example.com", text: $endPointUrl, onEditingChanged: { b in
                        guard !b else { return }
                        if self.domainName == "" {
                            self.domainName = extractDomainName(fromURL: self.endPointUrl)
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

struct EndPointEditView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                EndPointEditView()
            }
        }
    }
}
