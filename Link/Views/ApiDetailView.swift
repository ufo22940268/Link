//
//  EndPointDetailEditView.swift
//  Link
//
//  Created by Frank Cheng on 2020/7/31.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import SwiftUI

struct ApiDetailView: View {
    internal init(api: ApiEntity, onComplete: (() -> Void)? = nil) {
        self.api = api
        modelData = ApiDetailData(api: api)
    }

    @ObservedObject var api: ApiEntity
    @Environment(\.managedObjectContext) var context
    @State private var showingAlert = false
    @Environment(\.presentationMode) var presentationMode
    var onComplete: (() -> Void)?
    @State var cancellables = Set<AnyCancellable>()
    @ObservedObject var modelData: ApiDetailData

    var actionView: some View {
        if api.watch {
            return AnyView(Button("忽略监控", action: {
                self.showingAlert = true
            })
                .foregroundColor(.red)
                .alert(isPresented: $showingAlert, content: {
                    Alert(title: Text("确定取消监控吗?"), message: nil, primaryButton: .default(Text("确定"), action: {
                        self.api.watch = false
                        self.onComplete?()
                        NotificationCenter.default.post(Notification.init(name: Notification.updateJsonViewer))
                    }), secondaryButton: .cancel())
                }))
        } else {
            return AnyView(Button("加入监控", action: {
                self.api.watch = true
                self.api.watchValue = self.api.value
                self.onComplete?()
            }).foregroundColor(.accentColor))
        }
    }

    var body: some View {
        let watchValueBinding = Binding<String>(get: { () -> String in
            self.modelData.watchValue ?? ""
        }) { nv in
            self.modelData.watchValue = nv
        }

        return List {
            actionView

            Section(header: Text("Key")) {
                Text(api.paths ?? "")
            }

            Section(header: Text("value")) {
                Text(api.value ?? "")
                    .foregroundColor(api.match ? nil : .error)
            }

            if api.watch {
                Section(header: Text("期望值")) {
                    NavigationLink(destination: EditWatchValueView(watchValue: watchValueBinding)) {
                        Text(api.watchValue ?? "")
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text("字段"), displayMode: .inline)
        .onAppear {
            self.modelData.objectWillChange
                .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
                .sink { _ in
                    self.api.watch = self.modelData.watch
                    self.api.watchValue = self.modelData.watchValue
                    self.onComplete?()
                }
                .store(in: &self.cancellables)
        }
    }
}

struct ApiDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PreviewWrapper()
        }
    }

    struct PreviewWrapper: View {
        @State var api: ApiEntity = ApiEntity(context: getPersistentContainer().viewContext)

        var body: some View {
            api.paths = "asaa"
            api.value = "vvv"
            api.watch = true
            api.watchValue = "wefwef"
            return ApiDetailView(api: api).environment(\.colorScheme, .dark)
        }
    }
}
