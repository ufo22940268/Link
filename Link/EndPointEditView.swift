//
//  EndPointEditView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/20.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
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

enum ValidateURLResult {
    case formatError
    case requestError
    case jsonError
    case pending
    case ok

    var label: String {
        switch self {
        case .formatError:
            return "地址格式不对或不完整"
        case .requestError:
            return "地址请求失败"
        case .jsonError:
            return "返回并不是合法JSON"
        case .pending:
            return ""
        case .ok:
            return ""
        }
    }
}

class EndPointViewData: ObservableObject {
    @Published var endPointURL: String = ""

    var validEndPointURL: AnyPublisher<ValidateURLResult, Never> {
        let fetchPub = $endPointURL
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .flatMap { url in
                ApiHelper().test(url: url)
            }

        let emitFalse = $endPointURL.map { _ in ValidateURLResult.pending }

        return Publishers.Merge(fetchPub, emitFalse).eraseToAnyPublisher()
    }
}

struct EndPointEditView: View {
    @Environment(\.managedObjectContext) var context

    @EnvironmentObject var domainData: DomainData
    @State var cancellables = [AnyCancellable]()
    @State var urlTestResult: ValidateURLResult = .pending
    @Environment(\.presentationMode) var presentationMode
    @State var endPointId: NSManagedObjectID?
    @State var changeURLSubject = CurrentValueSubject<String, Never>("")

    @State var url: String = ""

    var doneButton: some View {
        return Button("完成") {
            print(Date(), "done")
            self.presentationMode.wrappedValue.dismiss()
        }.disabled(!isFormValid)
    }

    var isFormValid: Bool {
        urlTestResult == .ok
    }

    var domainName: String {
        extractDomainName(fromURL: url)
    }

    func updateEndPointEntity() {
        var endPoint: EndPointEntity

        if let endPointId = self.endPointId {
            endPoint = domainData.findEndPointEntity(by: endPointId)!
        } else if let nd = domainData.endPoints.first(where: { $0.url == self.url }) {
            endPoint = nd
        } else {
            endPoint = EndPointEntity(context: context)
            let domain = DomainEntity(context: context)
            domain.name = domainName
            endPoint.domain = domain
        }
        endPoint.url = url
        endPointId = endPoint.objectID

        do {
            try context.save()
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
    }

    fileprivate func listenToURLChange() {
        let fetchPub = changeURLSubject
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .flatMap { url in
                ApiHelper().test(url: url)
            }
        let falsePub = changeURLSubject.map { _ in ValidateURLResult.pending }
        Publishers.Merge(fetchPub, falsePub)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { result in
                self.urlTestResult = result
                if result == .ok {
                    self.updateEndPointEntity()
                }
            })
            .store(in: &cancellables)
    }

    var body: some View {
        var urlBinding = Binding<String>(get: {
            self.url
        }, set: {
            self.url = $0
            self.changeURLSubject.send($0)
        })

        return NavigationView {
            Form {
                Section(header: Text(""), footer: Text(urlTestResult.label)) {
                    HStack {
                        Text("域名地址")
                        Spacer()
                        TextField("https://example.com", text: urlBinding)
                            .multilineTextAlignment(.trailing)
                            .lineLimit(3)
                            .textContentType(.URL)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                    }
                    HStack {
                        Text("名字")
                        Spacer()
                        TextField("example", text: Binding.constant(self.domainName)).multilineTextAlignment(.trailing)
                    }
                }

                ApiEditView().environment(\.endPointId, endPointId)
            }
            .navigationBarTitle("输入域名", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("取消")
            }), trailing: doneButton)
            .onAppear {
                self.listenToURLChange()

                if ProcessInfo.processInfo.environment["FILL_URL"] != nil {
                    self.url = "http://biubiubiu.hopto.org:9000/link/github.json"
                    urlBinding.wrappedValue = "http://biubiubiu.hopto.org:9000/link/github.json"
                }
            }
        }
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
