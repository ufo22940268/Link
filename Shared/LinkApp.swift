//
//  LinkApp.swift
//  Shared
//
//  Created by Frank Cheng on 2020/10/9.
//

import SwiftUI

@main
struct LinkApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
