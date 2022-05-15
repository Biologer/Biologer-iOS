//
//  SwiftUIAlertViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 13.9.21..
//

import SwiftUI

public final class SwiftUIAlertViewControllerFactory: AlertViewControllerFactory {
    public func makeConfirmationAlert(popUpType: PopUpType,
                                      title: String,
                                      description: String,
                                      onTapp: @escaping Observer<Void> ) -> UIViewController {
        let screen = PopUpConfirmScreen(popUpType: popUpType,
                                        title: title,
                                        description: description,
                                        onButtonTapped: onTapp)
        let controller = UIHostingController(rootView: screen)
        controller.view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        return controller
    }
    
    public func makeYesAndNoAlert(title: String,
                                  onYesTapped: @escaping Observer<Void>,
                                  onNoTapped: @escaping Observer<Void>) -> UIViewController {
        let popUpScreen = PopUpYesAndNoScreen(title: title,
                                              onYesTapped: onYesTapped,
                                              onNoTapped: onNoTapped)
        let controller = UIHostingController(rootView: popUpScreen)
        controller.view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        return controller
    }
}
