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

struct ApiEditListItemView: View {
    @Binding var api: ApiEntity
    @Environment(\.editMode) var mode
    var selected: Bool = false

    var isEditing: Bool {
        mode != nil && mode!.wrappedValue.isEditing
    }

    var innerBody: some View {
        Text(api.paths ?? "")
    }

    var body: some View {
        NavigationLink(destination: ApiDetailView(api: $api)) {
            innerBody
        }
    }
}

class ApiEditData: ObservableObject {
    @Published var apis = [ApiEntity]()
}

struct ApiEditView: View {
    @State private var cancellables = [AnyCancellable]()
    @Environment(\.managedObjectContext) var context
    @ObservedObject var apiEditData: ApiEditData
    @EnvironmentObject var domainData: DomainData
    @Binding var dismissPresentationMode: PresentationMode?
    @State var segmentSelection = Segment.all.rawValue

    var doneButton: some View {
        Button("完成", action: {
            try? self.context.save()
            self.dismissPresentationMode?.dismiss()
        })
    }

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

    var categorySelectorView: some View {
        Picker("Select api category", selection: $segmentSelection) {
            ForEach(Segment.allCases, id: \.self.rawValue) { segment in
                Text(segment.label).tag(segment.rawValue)
            }
        }.pickerStyle(SegmentedPickerStyle()).fixedSize().padding()
    }

    var categoryApis: [ApiEntity] {
        if segmentSelection == Segment.all.rawValue {
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

            List {
                ForEach(self.categoryApis, id: \.self) { api in
                    ApiEditListItemView(api: self.getApiBinding(api), selected: api.watch)
                }
            }
        }.navigationBarItems(trailing: doneButton).navigationBarTitle("字段", displayMode: .inline)
    }
}

struct ApiEditView_Previews: PreviewProvider {
    static var previews: some View {
        let d = ApiEditData()
        let a = ApiEntity(context: context)
        a.paths = "wefwef"
        a.watch = true
        let a2 = ApiEntity(context: context)
        a2.paths = "wefwef2"
        a2.watch = false
        d.apis = [a, a2]
        return NavigationView {
            ApiEditView(apiEditData: d, dismissPresentationMode: Binding.constant(nil))
                .environment(\.managedObjectContext, context)
                .colorScheme(.light)
        }
    }
}
