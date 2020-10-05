//
//  SceneDelegate.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/16.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import CoreData
import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    private func requestNotificationAuth() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
        }

        UIApplication.shared.registerForRemoteNotifications()
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        requestNotificationAuth()

        if UIDevice.isSimulator {
            if let sqliteUrl = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.persistentStoreDescriptions.first?.url {
                let tmpFile = URL(fileURLWithPath: "/tmp/Application Support")
                try? FileManager.default.removeItem(at: tmpFile)
                try! FileManager.default.createSymbolicLink(at: tmpFile, withDestinationURL: sqliteUrl.deletingLastPathComponent())
                print("sqlite url", sqliteUrl.absoluteURL.description.removingPercentEncoding ?? "")
            }
        }

        if let _ = ProcessInfo.processInfo.environment["RESET_CORE_DATA"], !UIDevice.isRunningTest {
            DebugHelper.resetCoreData()
        }
        //

        // Create the SwiftUI view that  provides the window contents.
        let contentView = OnboardView()
            .environment(\.managedObjectContext, context)
//        let contentView = TestView()
//            .environment(\.managedObjectContext, context)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
//        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
