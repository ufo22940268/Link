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
    case prompt
    case initial
    case formatError
    case requestError
    case jsonError
    case pending
    case ok
    case duplicatedUrl

    var label: String {
        switch self {
        case .prompt:
            return "地址示例 http://biubiubiu.hopto.org:9000/link/github.json"
        case .initial:
            return ""
        case .formatError:
            return "地址格式不对或不完整, 需要以http://或者https://开头"
        case .duplicatedUrl:
            return "地址已存在"
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

struct EndPointEditView: View {
    @Environment(\.managedObjectContext) var context

    var dataSource: DataSource {
        DataSource(context: context)
    }

    @State var cancellables = Set<AnyCancellable>()
    @State var validateURLResult: ValidateURLResult = .initial
    @Environment(\.presentationMode) var presentationMode
    @State var apiEntitiesOfDomain = [ApiEntity]()

    @ObservedObject var apiEditData: ApiEditData
    @State var launched = false
    @State var customDomainName: Bool = false
    @State var textHeight: CGFloat = 90
    @State var showAdd: Bool = false

    var type: EditType

    internal init(type: EndPointEditView.EditType, apiEditData: ApiEditData = ApiEditData()) {
        self.type = type
        self.apiEditData = apiEditData

        if type == .add {
            _validateURLResult = State(initialValue: .prompt)
        }

        customDomainName = apiEditData.url.domainName == apiEditData.domainName
    }

    enum EditType {
        case edit
        case add
    }

    var editView: some View {
        ApiEditView(apiEditData: self.apiEditData)
            .environmentObject(apiEditData)
    }

    @State var selection: Int? = nil

    var doneButton: some View {
        NavigationLink(destination: editView, tag: 1, selection: $selection, label: {
            Button("下一步") {
                self.selection = 1
                self.dataSource.upsertDomainName(name: self.apiEditData.domainName, url: self.apiEditData.url)
            }
        }).disabled(!(validateURLResult == .ok))
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
            .map { url -> (String?, ValidateURLResult?) in
                self.validateURLResult = .pending
                if (self.type == .add && self.dataSource.isURLExists(url))
                    || (self.type == .edit && url != self.apiEditData.originURL && self.dataSource.isURLExists(url))
                {
                    return (nil, ValidateURLResult.duplicatedUrl)
                }
                return (url, nil)
            }
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .flatMap { url, result -> AnyPublisher<ValidateURLResult, Never> in
                if let result = result {
                    return Just(result).eraseToAnyPublisher()
                } else {
                    return ApiHelper(context: self.context).test(url: url!).eraseToAnyPublisher()
                }
            }
            .receive(on: DispatchQueue.main)
            .flatMap { result -> AnyPublisher<[ApiEntity], Never> in
                self.validateURLResult = result
                if result == .ok {
                    return ApiHelper(context: self.context)
                        .fetchAndUpdateEntity(endPoint: self.apiEditData.endPoint!)
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
            self.apiEditData.endPoint?.url = $0
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
            Section(header: Text("域名地址").bold(), footer: Text(validateURLResult.label).foregroundColor(validateURLResult.color)) {
                MultilineTextField(text: urlBinding, minHeight: self.textHeight, calculatedHeight: self.$textHeight)
                    .frame(minHeight: self.textHeight, maxHeight: self.textHeight)
            }

            Section(header: Text("名字").bold()) {
                TextField("", text: nameBinding)
            }

            if apiEditData.unwatchedApis.count > 0 {
                Section {
                    Button("添加字段...") {
                        self.showAdd = true
                    }
                }
            }
        }
        .background(
            NavigationLink(destination: ApiEditView(apiEditData: apiEditData), isActive: $showAdd) {
                EmptyView()
            }.hidden()
        )
        .navigationBarTitle("域名", displayMode: .inline)
        .navigationBarItems(leading: cancelButton, trailing: doneButton)
        .onAppear {
            if self.type == .edit {
                self.validateURLResult = .ok
            } else if self.type == .add {
                self.apiEditData.setEndPointForCreate()
            }

            self.listenToURLChange()

            if !self.launched {
                if ProcessInfo.processInfo.environment["FILL_URL"] != nil {
                    self.apiEditData.url = "http://biubiubiu.hopto.org:9000/link/github.json"
                    self.urlBinding.wrappedValue = "http://biubiubiu.hopto.org:9000/link/github.json"
                }
            }
        }
        .onDisappear {
            self.cancellables.forEach { $0.cancel() }
        }

        return NavigationView {
            form.navigationBarItems(leading: cancelButton, trailing: doneButton)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct EndPointEditView_Previews: PreviewProvider {
    static var previews: some View {
        let ee = EndPointEntity(context: context)
        ee.url = "http://wefwef.com"

        let domain = DomainEntity(context: context)
        domain.hostname = "wefwef.com"
        domain.name = "iii"

        let ae1 = ApiEntity(context: context)
        ae1.endPoint = ee
        ae1.paths = "p"
        ae1.value = "ae1.value"

        let ae2 = ApiEntity(context: context)
        ae2.endPoint = ee
        ae2.paths = "p"
        ae2.value = "ae1.value"

        ee.addToApi(ae1)
        ee.addToApi(ae2)

        let d = ApiEditData(endPointId: ee.objectID)
        d.endPoint = ee
        return EndPointEditView(type: .edit, apiEditData: d)
            .environment(\.managedObjectContext, context)
            .colorScheme(.dark)
    }
}
