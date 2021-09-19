//
//  TaxonRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.9.21..
//

import UIKit

public final class TaxonRouter {
    private let navigationController: UINavigationController
    private let factory: TaxonViewControllerFactory
    private let swiftUICommonFactory: CommonViewControllerFactory
    private let uiKitCommonFactory: CommonViewControllerFactory
    private let alertFactory: AlertViewControllerFactory
    public var onSideMenuTapped: Observer<Void>?
    
    init(navigationController: UINavigationController,
         factory: TaxonViewControllerFactory,
         swiftUICommonFactory: CommonViewControllerFactory,
         uiKitCommonFactory: CommonViewControllerFactory,
         alertFactory: AlertViewControllerFactory) {
        self.navigationController = navigationController
        self.factory = factory
        self.swiftUICommonFactory = swiftUICommonFactory
        self.uiKitCommonFactory = uiKitCommonFactory
        self.alertFactory = alertFactory
    }
    
    func start() {
        showLiftOfFindings()
    }
    
    // MARK: - Private Functions
    private func showLiftOfFindings() {
        let vc = factory.makeListOfFindingsScreen(onNewItemTapped: { _ in
                            
                                                  },
                                                  onItemTapped: { item in
                                                                        
                                                  })
        vc.setBiologerBackBarButtonItem(image: UIImage(named: "side_menu_icon")!,
                                        action: {
                                            self.onSideMenuTapped?(())
                                        })
        self.navigationController.setViewControllers([vc], animated: false)
    }
}
