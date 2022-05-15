//
//  AlertViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 13.9.21..
//

import UIKit

public protocol AlertViewControllerFactory {
    func makeConfirmationAlert(popUpType: PopUpType,
                               title: String,
                               description: String,
                               onTapp: @escaping Observer<Void>) -> UIViewController
    func makeYesAndNoAlert(title: String,
                           onYesTapped: @escaping Observer<Void>,
                           onNoTapped: @escaping Observer<Void>) -> UIViewController
}
