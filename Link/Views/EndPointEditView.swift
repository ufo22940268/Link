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

enum ValidateURLResult {
    case initial
    case formatError
    case requestError
    case jsonError
    case pending
    case ok

    var label: String {
        switch self {
        case .initial:
            return ""
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
    @State var validateURLResult: ValidateURLResult = .initial
    @Environment(\.presentationMode) var presentationMode
    @State var apiEntitiesOfDomain = [ApiEntity]()

    @ObservedObject var apiEditData: ApiEditData
    @State var launched = false
    @State var customDomainName: Bool = false

    var type: EditType

    internal init(type: EndPointEditView.EditType, apiEditData: ApiEditData = ApiEditData()) {
        self.type = type
        self.apiEditData = apiEditData

        if type == .add {
            validateURLResult = .initial
        }

        customDomainName = apiEditData.url.domainName == apiEditData.domainName
    }

    enum EditType {
        case edit
        case add
    }

    var editView: some View {
        ApiEditView(apiEditData: self.apiEditData, dismissPresentationMode: Binding(presentationMode))
            .environmentObject(apiEditData)
    }

    @State var selection: Int? = nil

    var doneButton: some View {
        NavigationLink(destination: editView, tag: 1, selection: $selection, label: {
            Button("下一步") {
                self.selection = 1
                self.dataSource.upsertDomainName(name: self.apiEditData.domainName, url: self.apiEditData.url)
            }.disabled(!(validateURLResult == .ok))
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

    fileprivate func listenToURLChange() {
        var urlPub: AnyPublisher<String, Never> = apiEditData.$url.eraseToAnyPublisher()
        if type == .edit {
            urlPub = urlPub.dropFirst().eraseToAnyPublisher()
        } else {
            urlPub = urlPub.filter {
                !(self.validateURLResult == .initial && $0 == "")
            }.eraseToAnyPublisher()
        }

        urlPub
            .filter { $0.isValidURL() }
            .map {
                self.validateURLResult = .pending
                return $0
            }
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .flatMap { url in
                ApiHelper().test(url: url)
            }
            .receive(on: DispatchQueue.main)
            .flatMap { result -> AnyPublisher<[ApiEntity], Never> in
                self.validateURLResult = result
                if result == .ok {
                    return ApiHelper()
                        .fetchAndUpdateEntity(endPoint: self.apiEditData.endPoint)
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

        apiEditData.$url
            .filter { !$0.isEmpty }
            .contains { !$0.isValidURL() }
            .sink { formatError in
                if formatError {
                    self.validateURLResult = .formatError
                }
            }
            .store(in: &cancellables)

        apiEditData.$url
            .filter { _ in !self.customDomainName }
            .map {
                $0.domainName
            }
            .assign(to: \.domainName, on: apiEditData)
            .store(in: &cancellables)
    }

    var urlBinding: Binding<String> {
        Binding<String>(get: {
            self.apiEditData.url
        }, set: {
            self.apiEditData.url = $0
        })
    }

    var nameBinding: Binding<String> {
        Binding<String>(get: { () -> String in
            self.apiEditData.domainName
        }) {
            self.apiEditData.domainName = $0
            self.customDomainName = true
        }
    }

    var body: some View {
        let form = Form {
            Section(header: Text(""), footer: Text(validateURLResult.label).foregroundColor(validateURLResult.color)) {
                HStack {
                    Text("域名地址")
                    Spacer()
                    TextField("https://example.com/api.json", text: urlBinding)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(3)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                HStack {
                    Text("名字")
                    Spacer()
                    TextField("example", text: nameBinding)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .navigationBarTitle("域名", displayMode: .inline)
        .navigationBarItems(leading: cancelButton, trailing: doneButton)
        .onAppear {
            if self.type == .edit {
                self.validateURLResult = .ok
            }

            self.listenToURLChange()

            if !self.launched {
                if ProcessInfo.processInfo.environment["FILL_URL"] != nil {
                    self.apiEditData.url = "http://biubiubiu.hopto.org:9000/link/github.json"
                    self.urlBinding.wrappedValue = "http://biubiubiu.hopto.org:9000/link/github.json"
                }
            }
        }

        return NavigationView { form.navigationBarItems(leading: cancelButton, trailing: doneButton) }
    }
}

struct EndPointEditView_Previews: PreviewProvider {
    static var previews: some View {
        let ee = EndPointEntity(context: context)
        ee.url = "http://wefwef.com"

        let domain = DomainEntity(context: context)
        domain.hostname = "wefwef.com"
        domain.name = "iii"

        return EndPointEditView(type: .edit, apiEditData: ApiEditData(endPoint: ee))
            .environment(\.managedObjectContext, context)
    }
}
