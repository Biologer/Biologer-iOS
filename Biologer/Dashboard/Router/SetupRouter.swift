//
//  SetupRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import UIKit

public final class SetupRouter {
    
    private let navigationController: UINavigationController
    private let factory: SetupViewControllerFactory
    public var onSideMenuTapped: Observer<Void>?
    
    init(navigationController: UINavigationController,
         factory: SetupViewControllerFactory) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    public func start() {
        showSetupScreen()
    }
    
    // MARK: - Private Functions
    private func showSetupScreen() {
        let vc = factory.makeSetupScreen(onItemTapped: { item in
            // Present some screen by item type
        })
        vc.setBiologerBackBarButtonItem(image: UIImage(named: "side_menu_icon")!,
                                        action: {
                                            self.onSideMenuTapped?(())
                                        })
        self.navigationController.setViewControllers([vc], animated: false)
    }
}
