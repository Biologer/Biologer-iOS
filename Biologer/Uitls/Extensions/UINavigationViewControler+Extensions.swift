//
//  UINavigationViewControler+Extensions.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.7.21..
//

import UIKit

extension UINavigationController {
//    func setNavigationBarTransparency(_ isTransparent: Bool = true) {
//        if isTransparent {
//            navigationBar.isTranslucent = true
//            navigationBar.shadowImage = UIImage()
//            navigationBar.setBackgroundImage(UIImage(), for: .default)
//        } else {
//            navigationBar.isTranslucent = false
//            navigationBar.shadowImage = nil
//            navigationBar.setBackgroundImage(nil, for: .default)
//        }
//   }
    
//    public func setNavigationBarTransparent(_ transparent: Bool) {
//        let appearance = UINavigationBarAppearance()
//        transparent ? appearance.configureWithTransparentBackground() : appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = transparent ? .clear : .biologerGreenColor
//        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
//        //appearance.setBackIndicatorImage(UIImage.backArrow, transitionMaskImage: UIImage.backArrow)
//
//        navigationBar.standardAppearance = appearance
//        navigationBar.scrollEdgeAppearance = appearance
//        navigationBar.compactAppearance = appearance
//
//    }

    public func pushViewController(viewController: UIViewController,
                                   animated: Bool,
                                   completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}
