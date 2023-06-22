//
//  SceneDelegate.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import UIKit
import SwiftUI
import BackgroundTasks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var navigationController: BiologerNavigationViewController!
    var appRouter: AppNavigationRouter?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            navigationController = BiologerNavigationViewController(shouldBeTransparent: true)
            let window = UIWindow(windowScene: windowScene)
            appRouter = AppNavigationRouter(mainNavigationController: navigationController)
            appRouter?.start()
            window.rootViewController = navigationController
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    private func startApp() {
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
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
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.biologer.paginationBackgroundTask", using: nil) { task in
//            //self.backgoundTask = task as? BGProcessingTask
//            print("BACKGROUDN TASK REGISTRED!")
//        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

