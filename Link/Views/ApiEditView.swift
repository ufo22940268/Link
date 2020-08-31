//
//  EndPointEditView.swift
//  Link
//
//  Created by Frank Cheng on 2020/7/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

enum Segment: Int, RawRepresentable, CaseIterable {
    case all = 0
    case watch = 1

    var label: String {
        switch self {
        case .all:
            return "全部"
        case .watch:
            return "已关注"
        }
    }
}

struct ApiEditView: View {
    private var cancellables = [AnyCancellable]()
    @Environment(\.managedObjectContext) var context
    @ObservedObject var apiEditData: ApiEditData
    @State var segment = Segment.all.rawValue

    init(apiEditData: ApiEditData) {
        self.apiEditData = apiEditData
    }

    func buildApiSelection() -> Binding<Set<ApiEntity>> {
        Binding<Set<ApiEntity>>(get: { () -> Set<ApiEntity> in
            Set<ApiEntity>(self.apiEditData.apis.filter { $0.watch })
        }) { apis in
            self.apiEditData.apis.forEach { api in
                api.watch = apis.contains(api)
            }
        }
    }

//    var doneButton: some View {
//        if editMode != .active {
//            return AnyView(Button("完成", action: {
//                try! self.context.save()
//                try! CoreDataContext.main.save()
//                self.dismissPresentationMode?.dismiss()
//            }))
//        } else {
//            return AnyView(EmptyView())
//        }
//    }

    var unwatchApis: [ApiEntity] {
        return apiEditData.apis.filter { !$0.watch }
    }

    func getApiBinding(_ api: ApiEntity) -> Binding<ApiEntity> {
        let index = apiEditData.apis.firstIndex(of: api)!
        return $apiEditData.apis[index]
    }

    var body: some View {
        VStack {
            List(self.unwatchApis, id: \.self) { api -> AnyView in
                AnyView(ApiListItemView(api: self.getApiBinding(api)))
            }
        }
        .navigationBarTitle("添加字段", displayMode: .inline)
    }
}

struct ApiEditView_Previews: PreviewProvider {
    static var previews: some View {
        let d = ApiEditData()
        let a = ApiEntity(context: context)
        a.paths = "aa.bnb.cc.wefwef"
        a.value = "CoreData: error: Failed to call designated initializer on NSManagedObject class 'Link.EndPointEntity' CoreData: error: Failed to call designated initializer on NSManagedObject class 'Link.EndPointEntity'"
        a.watch = true
        let a2 = ApiEntity(context: context)
        a2.paths = "wefwef2.wef"
        a2.value = "12322"
        a2.watch = false
        d.apis = [a, a2]
        return NavigationView {
            ApiEditView(apiEditData: d)
                .environment(\.managedObjectContext, context)
                .colorScheme(.light)
        }
    }
}
