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
    func makeBiologerProgressBarView(maxValue: Double,
                                     currentValue: Double,
                                     onProgressAppeared: @escaping Observer<Double>,
                                     onCancelTapped: @escaping Observer<Double>) -> UIViewController
}

//public final class IOSUIKitCommonViewControllerFactory: CommonViewControllerFactory {
//    public func makeLicenseScreen(items: [CheckMarkItem],
//                                      selectedItem: CheckMarkItem,
//                                      delegate: CheckMarkScreenDelegate?,
//                                      onItemTapped: @escaping Observer<CheckMarkItem>) -> UIViewController {
//        fatalError("There is no UIKit license screen")
//    }
//    
//    public func createBlockingProgress() -> UIViewController {
//        let progressViewController = BlokingProgressViewController(nibName: nil, bundle: nil)
//        progressViewController.modalTransitionStyle = .crossDissolve
//        progressViewController.modalPresentationStyle = .overFullScreen
//        return progressViewController
//    }
//    
//    public func makeHelpScreen(onDone: @escaping Observer<Void>) -> UIViewController {
//        fatalError("There is no UIKit help screen")
//    }
//    
//    public func makeBiologerProgressBarView(maxValue: Double,
//                                            currentValue: Double,
//                                            onProgressAppeared: @escaping Observer<Double>,
//                                            onCancelTapped: @escaping Observer<Double>) -> UIViewController {
//        fatalError("There is no swiftUI progress bar")
//    }
//}

public final class CommonViewControllerFactroryImplementation: CommonViewControllerFactory {
    
    public func createBlockingProgress() -> UIViewController {
        let progressViewController = BlokingProgressViewController(nibName: nil, bundle: nil)
        progressViewController.modalTransitionStyle = .crossDissolve
        progressViewController.modalPresentationStyle = .overFullScreen
        return progressViewController
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
    
    public func makeBiologerProgressBarView(maxValue: Double,
                                            currentValue: Double = 0.0,
                                            onProgressAppeared: @escaping Observer<Double>,
                                            onCancelTapped: @escaping Observer<Double>) -> UIViewController {
        let viewModel = BiologerProgressBarScreenViewModel(maxValue: maxValue,
                                              currentValue: currentValue,
                                              onProgressAppeared: onProgressAppeared,
                                              onCancelTapped: onCancelTapped)
        let screen = BiologerProgressBarScreen(viewModel: viewModel)
        let controller = UIHostingController.init(rootView: screen)
        controller.view.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        return controller
    }
}
