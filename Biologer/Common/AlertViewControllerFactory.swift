//
//  AlertViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 13.9.21..
//

import UIKit

public protocol AlertViewControllerFactory {
    func makeErrorAlert(title: String, description: String, onTapp: @escaping Observer<Void>) -> UIViewController
}
