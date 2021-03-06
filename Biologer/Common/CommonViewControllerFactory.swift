//
//  CommonViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 12.7.21..
//

import SwiftUI

public protocol CommonViewControllerFactory {
    func createBlockingProgress() -> UIViewController
    func makeLicenseScreen(items: [CheckMarkItem],
                           selectedItem: CheckMarkItem,
                           delegate: CheckMarkScreenDelegate?,
                           onItemTapped: @escaping Observer<CheckMarkItem>) -> UIViewController
    func makeHelpScreen(onDone: @escaping Observer<Void>) -> UIViewController
}

public final class IOSUIKitCommonViewControllerFactory: CommonViewControllerFactory {
    public func makeLicenseScreen(items: [CheckMarkItem],
                                      selectedItem: CheckMarkItem,
                                      delegate: CheckMarkScreenDelegate?,
                                      onItemTapped: @escaping Observer<CheckMarkItem>) -> UIViewController {
        fatalError("There is no UIKit license screen")
    }
    
    public func createBlockingProgress() -> UIViewController {
        let progressViewController = BlokingProgressViewController(nibName: nil, bundle: nil)
        progressViewController.modalTransitionStyle = .crossDissolve
        progressViewController.modalPresentationStyle = .overFullScreen
        return progressViewController
    }
    
    public func makeHelpScreen(onDone: @escaping Observer<Void>) -> UIViewController {
        fatalError("There is no UIKit help screen")
    }
}

public final class SwiftUICommonViewControllerFactrory: CommonViewControllerFactory {
    
    public func createBlockingProgress() -> UIViewController {
        fatalError("There is no swiftUI progress loader")
    }
    
    public func makeLicenseScreen(items: [CheckMarkItem],
                                  selectedItem: CheckMarkItem,
                                  delegate: CheckMarkScreenDelegate?,
                                  onItemTapped: @escaping Observer<CheckMarkItem>) -> UIViewController {
        
        let viewModel = CheckMarkScreenViewModel(items: items,
                                                 selectedItem: selectedItem,
                                                 delegate: delegate,
                                                 onItemTapped: onItemTapped)
        
        let screen = CheckMarkScreen(loader: viewModel)
        let viewController = UIHostingController(rootView: screen)
        return viewController
    }
    
    public func makeHelpScreen(onDone: @escaping Observer<Void>) -> UIViewController {
        let viewModel = HelpScreenViewModel(onDone: onDone)
        let screen = HelpScreen(loader: viewModel)
        let vc = UIHostingController(rootView: screen)
        return vc
    }
}
