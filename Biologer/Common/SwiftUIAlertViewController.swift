//
//  SwiftUIAlertViewController.swift
//  Biologer
//
//  Created by Nikola Popovic on 13.9.21..
//

import SwiftUI

public final class SwiftUIAlertViewController: AlertViewControllerFactory {
    public func makeErrorAlert(title: String, description: String, onTapp: @escaping Observer<Void> ) -> UIViewController {
        let screen = PopUpErrorScreen(title: title,
                                      description: description,
                                      onButtonTapped: onTapp)
        let controller = UIHostingController(rootView: screen)
        controller.view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        return controller
    }
}
