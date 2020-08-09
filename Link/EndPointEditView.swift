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
    @ObservedObject var viewData: EndPointViewData = EndPointViewData()

    var endPointUrl: String {
        viewData.endPointURL
    }

    @FetchRequest(entity: EndPointEntity.entity(), sortDescriptors: []) var endPoints: FetchedResults<EndPointEntity>
    @EnvironmentObject var domainData: DomainData
    @State var cancellables = [AnyCancellable]()
    @State var urlTestResult: ValidateURLResult = .pending
    @State var createdEndPoint: EndPointEntity?

    var nextButton: some View {
        NavigationLink(destination: ApiEditView(), label: { Text("下一步") }).simultaneousGesture(TapGesture().onEnded {
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
            self.createdEndPoint = endPoint
        }).disabled(!isFormValid)
    }

    var isFormValid: Bool {
        urlTestResult == .ok
    }

    var domainName: String {
        extractDomainName(fromURL: endPointUrl)
    }

    var body: some View {
        Form {
            Section(header: Text(""), footer: Text(urlTestResult.label)) {
                HStack {
                    Text("域名地址")
                    Spacer()
                    TextField("https://example.com", text: $viewData.endPointURL)
                        .multilineTextAlignment(.trailing)
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
        }
        .navigationBarTitle("输入域名", displayMode: .inline)
        .navigationBarItems(trailing: nextButton)
        .onAppear {
            self.viewData.validEndPointURL
                .assign(to: \.urlTestResult, on: self)
                .store(in: &self.cancellables)
            
            if ProcessInfo.processInfo.environment["FILL_URL"] != nil {
                self.viewData.endPointURL = "http://biubiubiu.hopto.org:9000/link/github2.json"
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
