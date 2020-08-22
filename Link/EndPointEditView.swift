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
            return "检查中..."
        case .ok:
            return "地址正常"
        }
    }

    var color: Color? {
        switch self {
        case .formatError, .requestError, .jsonError:
            return .red
        default:
            return nil
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

    var dataSource: DataSource {
        DataSource(context: context)
    }

    @State var cancellables = [AnyCancellable]()
    @State var urlTestResult: ValidateURLResult = .pending
    @Environment(\.presentationMode) var presentationMode
    @State var endPointId: NSManagedObjectID?
    @State var changeURLSubject = CurrentValueSubject<String, Never>("")
    @State var apiEntitiesOfDomain = [ApiEntity]()

    @State var url: String = ""
    @State var apiEditData: ApiEditData = ApiEditData()
    @State var launched = false

    var type: EditType

    enum EditType {
        case edit
        case add
    }

    var editView: some View {
        ApiEditView(apiEditData: self.apiEditData, dismissPresentationMode: Binding(presentationMode))
            .environmentObject(apiEditData)
    }

    var doneButton: some View {
        NavigationLink(destination: editView, label: {
            Text("下一步").disabled(!isFormValid)
        })
    }

    var cancelButton: some View {
        Button(action: {
            self.context.rollback()
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("取消")
        })
    }

    var isFormValid: Bool {
        urlTestResult == .ok
    }

    @State var domainName: String = ""

    func updateEndPointEntity() {
        var endPoint: EndPointEntity

        var needSave = false
        if let endPointId = self.endPointId {
            endPoint = dataSource.fetchEndPoint(id: endPointId)!
        } else if let nd = dataSource.fetchEndPoint(url: url) {
            endPoint = nd
        } else {
            endPoint = EndPointEntity(context: context)
            let domain = DomainEntity(context: context)
            domain.name = domainName
            endPoint.domain = domain
            needSave = true
        }
        endPoint.url = url
        endPointId = endPoint.objectID

        if needSave {
            print("save in update entity")
            try! context.save()
        }
    }

    fileprivate func listenToURLChange() {
        let fetchPub = changeURLSubject
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .flatMap { url in
                ApiHelper().test(url: url)
            }

        fetchPub
            .receive(on: DispatchQueue.main)
            .flatMap { result -> AnyPublisher<[ApiEntity], Never> in
                self.urlTestResult = result
                if result == .ok {
                    self.updateEndPointEntity()
                    return ApiHelper()
                        .fetch(endPoint: self.dataSource.fetchEndPoint(id: self.endPointId!)!)
                        .catch { _ in Just([]) }
                        .eraseToAnyPublisher()
                } else {
                    return Just([]).eraseToAnyPublisher()
                }
            }
            .sink { apis in
                self.apiEditData.apis = apis
            }
            .store(in: &cancellables)

        changeURLSubject
            .map {
                extractDomainName(fromURL: $0)
            }
            .assign(to: \.domainName, on: self)
            .store(in: &cancellables)
    }

    var body: some View {
        let urlBinding = Binding<String>(get: {
            self.url
        }, set: {
            self.url = $0
            self.changeURLSubject.send($0)
        })

        let form = Form {
            Section(header: Text(""), footer: Text(urlTestResult.label).foregroundColor(urlTestResult.color)) {
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
                    Text(domainName)
                }
            }
        }
        .navigationBarTitle("域名", displayMode: .inline)
        .navigationBarItems(leading: cancelButton, trailing: doneButton)
        .onAppear {
            self.listenToURLChange()
            if !self.launched {
                if ProcessInfo.processInfo.environment["FILL_URL"] != nil {
                    self.url = "http://biubiubiu.hopto.org:9000/link/github.json"
                    urlBinding.wrappedValue = "http://biubiubiu.hopto.org:9000/link/github.json"
                }
            }
        }

        return NavigationView { form.navigationBarItems(leading: cancelButton, trailing: doneButton) }
    }
}

struct EndPointEditView_Previews: PreviewProvider {
    static var previews: some View {
        let v2 = EndPointEditView(apiEditData: ApiEditData(), type: .edit)
        v2.urlTestResult = .formatError

        return Group {
            EndPointEditView(apiEditData: ApiEditData(), type: .edit)
            v2
        }
    }
}
