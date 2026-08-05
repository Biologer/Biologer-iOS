//
//  SceneDelegate.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appRootComposition: AppRootComposition?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let composition = AppRootComposition()
        let window = UIWindow(windowScene: windowScene)
        appRootComposition = composition
        window.rootViewController = UIHostingController(
            rootView: AppRootFlow(composition: composition)
        )
        self.window = window
        window.makeKeyAndVisible()
    }
}
