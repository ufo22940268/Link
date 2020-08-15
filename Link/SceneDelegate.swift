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

    private func launchView() -> some View {
        if let viewName = ProcessInfo.processInfo.environment["LAUNCH_VIEW"] {
            switch viewName {
//            case "endPointEdit":
//                let testDomain = DomainData.test(context: context)
//                return AnyView(
//                    EndPointEditView(endPointId: testDomain.endPoints.first!.objectID)
//                        .environment(\.managedObjectContext, context)
//                        .environmentObject(testDomain)
//                )
//            case "apiEdit":
//                let d = DomainData.test(context: context)
//                let endPointEditview = NavigationView {
//                    ApiEditView(apiEditData: ApiEditData())
//                        .environment(\.managedObjectContext, context)
//                        .environmentObject(d)
//                        .environment(\.endPointId, d.endPoints[0].objectID)
//                }
//                return AnyView(endPointEditview)
//            case "jsonViewer":
//                let view = JSONViewerView()
//                    .environmentObject(DomainData.test(context: context))
//                    .environmentObject(EndPointData(endPoint: try! getAnyEndPoint()))
//                return AnyView(NavigationView { view })
            case "jsonView":
                let d = """
                {"a": 1, "aa": 3, "d": 4, "b": "2/wefwef"}
                """.data(using: .utf8)!
                let view = JSONView(data: d, healthy: ["b"])
                return AnyView(view)
            default:
                fatalError()
            }
        }

        let mainView = OnboardView()
            .environment(\.managedObjectContext, context)
            .environmentObject(DataSource(context: context))
        return AnyView(mainView)
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        let sqliteUrl = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.persistentStoreDescriptions.first?.url?.absoluteURL.description ?? ""
        print("sqlite url", sqliteUrl.removingPercentEncoding ?? "")

        if let _ = ProcessInfo.processInfo.environment["RESET_CORE_DATA"] {
            DebugHelper.resetCoreData()
        }
        //

        // Create the SwiftUI view that provides the window contents.
        let contentView = launchView()

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
