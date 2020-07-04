//
//  DomainEditView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/20.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI
import CoreData

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
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var domainUrl: String = ""
    @State var domainName: String = ""
    @FetchRequest(entity: Domain.entity(), sortDescriptors: []) var domains: FetchedResults<Domain>
    
    var nextButton: some View {
        Button(action: {
            print(self.domains)
            var d: Domain
            if let nd =  self.domains.first(where: {$0.url == self.domainUrl}) {
                d = nd
            } else {
                d = Domain(context: self.managedObjectContext)
                d.url = self.domainUrl
            }
            d.name = self.domainName
            do {
                try self.managedObjectContext.save()
            } catch let error as NSError {
                print("Error: \(error), \(error.userInfo)")
            }
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
//        .navigationBarItems(trailing: HStack(spacing: 20) {
//            Button("read") {
////                print(self.domains)
////                FetchRequest(entity: Domain.entity(), sortDescriptors: []).
//                let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Domain")
//                let r = try? self.managedObjectContext.fetch(request)
////                let r = try? request.execute()
//                print(r)
//            }
//            Button("write") {
//                print("write")
//                let d = Domain(context: self.managedObjectContext)
//                d.url = "asdfasdf"
//                d.name = "jj"
//                do {
//                    try self.managedObjectContext.save()
//                } catch let error as NSError {
//                    print("Error: \(error), \(error.userInfo)")
//                }
//            }
//        })
    }
}

struct DomainEditView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                DomainEditView()
            }
        }
    }
}
