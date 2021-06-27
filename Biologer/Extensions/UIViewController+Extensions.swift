//
//  UIViewController+Extensions.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import UIKit

extension UIViewController {
    public func setBiologerBackBarButtonItem(image: UIImage, target: Any, action: Selector) {
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        barButtonItem.tintColor = .white
        navigationItem.leftBarButtonItems = [barButtonItem]
    }
}
