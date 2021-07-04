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
    
    public func setBiologerBackBarButtonItem(target: Any, action: Selector) {
        let image = UIImage(named: "back_arrow")
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        barButtonItem.tintColor = UIColor.darkGray
        navigationItem.leftBarButtonItems = [barButtonItem]
    }
    
    public func setBiologerTitle(text: String, numberOfLines: Int = 0) {
        let titleLbl = UILabel()
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.darkGray, .kern: 1.0]
        let atributedString = NSAttributedString(string: text.uppercased(), attributes: attributes)
        titleLbl.attributedText = atributedString
        titleLbl.numberOfLines = numberOfLines
        titleLbl.textAlignment = .center
        titleLbl.sizeToFit()
        self.navigationItem.titleView = titleLbl
    }
}
