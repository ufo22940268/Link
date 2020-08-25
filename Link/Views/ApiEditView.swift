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
    @State private var cancellables = [AnyCancellable]()
    @Environment(\.managedObjectContext) var context
    @ObservedObject var apiEditData: ApiEditData
    @Binding var dismissPresentationMode: PresentationMode?
    @State var segment = Segment.all.rawValue
    @State var selection = Set<ApiEntity>()
    @State var editMode: EditMode = .inactive

    init(apiEditData: ApiEditData, dismissPresentationMode: Binding<PresentationMode?>) {
        self.apiEditData = apiEditData
        _dismissPresentationMode = dismissPresentationMode
        _selection = State(initialValue: Set(apiEditData.apis.filter { $0.watch }))
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

    var doneButton: some View {
        if editMode != .active {
            return AnyView(Button("完成", action: {
                try? self.context.save()
                self.dismissPresentationMode?.dismiss()
            }))
        } else {
            return AnyView(EmptyView())
        }
    }

    var editButton: some View {
        Button(self.editMode == .active ? "完成" : "编辑") {
            withAnimation {
                if self.editMode == .active {
                    self.editMode = .inactive
                    self.selection.forEach { api in
                        api.watch = true
                        api.watchValue = api.value
                    }
                    self.apiEditData.apis.filter { !self.selection.contains($0) }
                        .forEach {
                            $0.watch = false
                            $0.watchValue = nil
                        }
                    self.apiEditData.objectWillChange.send()
                } else {
                    self.editMode = .active
                }
            }
        }
    }

    var categorySelectorView: some View {
        Picker("Select api category", selection: $segment) {
            ForEach(Segment.allCases, id: \.self.rawValue) { segment in
                Text(segment.label).tag(segment.rawValue)
            }
        }.pickerStyle(SegmentedPickerStyle()).fixedSize().padding()
    }

    var categoryApis: [ApiEntity] {
        if segment == Segment.all.rawValue {
            return apiEditData.apis
        } else {
            return apiEditData.apis.filter { $0.watch }
        }
    }

    func getApiBinding(_ api: ApiEntity) -> Binding<ApiEntity> {
        let index = apiEditData.apis.firstIndex(of: api)!
        return $apiEditData.apis[index]
    }

    var body: some View {
        VStack {
            categorySelectorView
            List(self.categoryApis, id: \.self, selection: self.$selection) { api -> AnyView in
                AnyView(ApiEditListItemView(api: self.getApiBinding(api), segment: Segment.allCases.first { $0.rawValue == self.segment }!, onComplete: {
                    self.apiEditData.objectWillChange.send()
                }))
            }
        }
        .environment(\.editMode, $editMode)
        .navigationBarItems(leading: editButton, trailing: doneButton)
        .navigationBarTitle("字段", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
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
            ApiEditView(apiEditData: d, dismissPresentationMode: Binding.constant(nil))
                .environment(\.managedObjectContext, context)
                .colorScheme(.light)
        }
    }
}
