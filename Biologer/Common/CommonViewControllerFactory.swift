//
//  CommonViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 12.7.21..
//

import UIKit

public protocol CommonViewControllerFactory {
    func createBlockingProgress() -> UIViewController
}

public final class IOSUIKitCommonViewControllerFactory: CommonViewControllerFactory {
    public func createBlockingProgress() -> UIViewController {
        let progressViewController = BlokingProgressViewController(nibName: nil, bundle: nil)
        progressViewController.modalTransitionStyle = .crossDissolve
        progressViewController.modalPresentationStyle = .overFullScreen
        return progressViewController
    }
}
