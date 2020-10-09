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
	@Environment(\.scenePhase) private var scenePhase

	init() {
		setupDBFile()
		resetCoreData()
	}
	
	func setupDBFile() {
		if MyDevice.isSimulator  {
			if let sqliteUrl = persistenceController.container.persistentStoreDescriptions.first?.url {
				let tmpFile = URL(fileURLWithPath: "/tmp/Application Support")
				try? FileManager.default.removeItem(at: tmpFile)
				try! FileManager.default.createSymbolicLink(at: tmpFile, withDestinationURL: sqliteUrl.deletingLastPathComponent())
				print("sqlite url", sqliteUrl.absoluteURL.description.removingPercentEncoding ?? "")
			}
		}
	}
	
	func resetCoreData() {
		if let _ = ProcessInfo.processInfo.environment["RESET_CORE_DATA"], !MyDevice.isRunningTest {
			DebugHelper.resetCoreData()
		}
				
	}
	
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
	
}
