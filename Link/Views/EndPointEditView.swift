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

enum EditType {
    case edit
    case add
}

struct EndPointEditView: View {
    var context: NSManagedObjectContext

    var dataSource: DataSource {
        DataSource(context: context)
    }

    @Environment(\.presentationMode) var presentationMode
    @State var apiEntitiesOfDomain = [ApiEntity]()

    @StateObject var apiEditData: EndPointEditData = EndPointEditData()
    @State var launched = false
    @State var customDomainName: Bool = false
    @State var textHeight: CGFloat = 90
    @State var showAdd: Bool = false
    @State var name: String = ""

    var type: EditType

    internal init(type: EditType, endPoint: NSManagedObjectID? = nil) {
        self.type = type
        
        switch type {
        case .add:
            context = CoreDataContext.add
            apiEditData.setupForCreate()
        case .edit:
            if endPoint == nil {
                fatalError("end point id is needed for edit mode.")
            }
            context = CoreDataContext.edit
            apiEditData.setupForEdit(endPointId: endPoint!)
        }

        // TODO:
//        customDomainName = apiEditData.url.domainName == apiEditData.domainName
    }

    var editView: some View {
        ApiEditView(apiEditData: self.apiEditData)
            .environmentObject(apiEditData)
    }

    var doneButton: some View {
        Button("完成") {
            self.dataSource.upsertDomainName(name: self.apiEditData.domainName, url: self.apiEditData.url)
            self.apiEditData.upsertEndPointInServer()
            try! self.context.saveToDB()
            self.presentationMode.wrappedValue.dismiss()
        }.disabled(!(apiEditData.validateURLResult == .ok && apiEditData.watchApis.count > 0))
    }

    var cancelButton: some View {
        Button(action: {
            self.context.rollback()
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("取消")
        })
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

    func createBinding(api: ApiEntity) -> Binding<ApiEntity> {
        return Binding.constant(api)
    }

    var body: some View {
        let showAdd = apiEditData.unwatchApis.count > 0
        let watchListCount = showAdd ? apiEditData.watchApis.count + 1 : apiEditData.watchApis.count

        let form = Form {
            Section(header: Text("域名地址"), footer: Text(apiEditData.validateURLResult.label).foregroundColor(apiEditData.validateURLResult.color)) {
                MultilineTextField(text: urlBinding, minHeight: self.textHeight, calculatedHeight: self.$textHeight)
                    .frame(minHeight: self.textHeight, maxHeight: self.textHeight)
            }

            Section(header: Text("名字")) {
                TextField("", text: nameBinding)
            }

            Section(header: Text("监控")) {
                ForEach(Array(0 ..< watchListCount), id: \.self) { i -> AnyView in
                    if i < self.apiEditData.watchApis.count {
                        let api: ApiEntity = self.apiEditData.watchApis[i]
                        return AnyView(
                            NavigationLink(destination: ApiDetailView(api: api), label: {
                                ApiListItemView(api: self.createBinding(api: api), showDisclosure: false) {
                                }
                            })
                        )
                    } else {
                        return AnyView(
                            Button("添加字段...") {
                                self.showAdd = true
                            }
                        )
                    }
                }
            }
        }
        .navigationBarTitle("域名", displayMode: .inline)
        .navigationBarItems(leading: cancelButton, trailing: doneButton)
        .onReceive(apiEditData.$url, perform: { url in
            if !self.customDomainName {
                self.apiEditData.domainName = url.domainName
            }
        })
        .sheet(isPresented: $showAdd, onDismiss: { self.apiEditData.objectWillChange.send() }, content: {
            NavigationView {
                ApiEditView(apiEditData: apiEditData)
            }
        })
        .onAppear {
            if !self.launched {
                if ProcessInfo.processInfo.environment["FILL_URL"] != nil {
                    self.apiEditData.url = "http://biubiubiu.hopto.org:9000/link/github.json"
                    self.urlBinding.wrappedValue = "http://biubiubiu.hopto.org:9000/link/github.json"
                }
            }
        }
        return NavigationView {
            form
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
        ae1.watch = true
        ae1.value = "ae1.value"

        let ae2 = ApiEntity(context: context)
        ae2.endPoint = ee
        ae2.paths = "p"
        ae2.value = "ae1.value"

        ee.addToApi(ae1)
        ee.addToApi(ae2)

        let d = EndPointEditData()
        d.endPoint = ee
        return EndPointEditView(type: .add)
            .environment(\.managedObjectContext, context)
            .colorScheme(.light)
    }
}
