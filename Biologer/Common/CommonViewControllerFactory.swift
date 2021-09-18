//
//  CommonViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 12.7.21..
//

import SwiftUI

public protocol CommonViewControllerFactory {
    func createBlockingProgress() -> UIViewController
    func makeLicenseScreen(dataLicenses: [CheckMarkItem],
                           selectedDataLicense: CheckMarkItem,
                           delegate: DataLicenseScreenDelegate?,
                           onLicenseTapped: @escaping Observer<CheckMarkItem>) -> UIViewController
}

public final class IOSUIKitCommonViewControllerFactory: CommonViewControllerFactory {
    public func makeLicenseScreen(dataLicenses: [CheckMarkItem],
                                  selectedDataLicense: CheckMarkItem,
                                  delegate: DataLicenseScreenDelegate?,
                                  onLicenseTapped: @escaping Observer<CheckMarkItem>) -> UIViewController {
        fatalError("There is no UIKit license screen")
    }
    
    public func createBlockingProgress() -> UIViewController {
        let progressViewController = BlokingProgressViewController(nibName: nil, bundle: nil)
        progressViewController.modalTransitionStyle = .crossDissolve
        progressViewController.modalPresentationStyle = .overFullScreen
        return progressViewController
    }
}

public final class SwiftUICommonViewControllerFactrory: CommonViewControllerFactory {
    
    public func createBlockingProgress() -> UIViewController {
        fatalError("There is no swiftUI progress loader")
    }
    
    public func makeLicenseScreen(dataLicenses: [CheckMarkItem],
                                  selectedDataLicense: CheckMarkItem,
                                  delegate: DataLicenseScreenDelegate?,
                                  onLicenseTapped: @escaping Observer<CheckMarkItem>) -> UIViewController {
        
        
        let viewModel = CheckMarkScreenViewModel(dataLicenses: dataLicenses,
                                                   selectedDataLicense: selectedDataLicense,
                                                   delegate: delegate,
                                                   onLicenseTapped: onLicenseTapped)
        
        let screen = CheckMarkScreen(loader: viewModel)
        let viewController = UIHostingController(rootView: screen)
        return viewController
    }

}
