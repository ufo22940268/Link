//
//  SettingView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/29.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var domainData: LinkData

    var body: some View {
        NavigationView {
            List {
                Section {
                    Button("退出登录") {
                        domainData.logout()
                    }
                }

                if !MyDevice.isRelease {
                    Section(header: Text("服务器")) {
                        Text(MyDevice.apiEnv.domain)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("更多")
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
