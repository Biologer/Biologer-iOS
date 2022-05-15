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
        barButtonItem.tintColor = UIColor.darkText
        navigationItem.leftBarButtonItems = [barButtonItem]
    }
    
    public func setBiologerBackBarButtonItem(image: UIImage? = nil, action: @escaping () -> Void) {
        removeBackButtonItem()
        let barButtonItem = UIBarButtonItem(image: image ?? UIImage(named: "back_arrow"), style: .plain, action: action)
        barButtonItem.tintColor = UIColor.darkText
        navigationItem.leftBarButtonItems = [barButtonItem]
    }
    
    public func setBiologerBackBarButtonItem(target: Any, action: Selector) {
        removeBackButtonItem()
        let image = UIImage(named: "back_arrow")
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        barButtonItem.tintColor = UIColor.darkText
        navigationItem.leftBarButtonItems = [barButtonItem]
    }
    
    public func setBiologerRightButtonItem(image: UIImage? = nil, title: String = "", target: Any, action: Selector) {
        let image = image
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        barButtonItem.tintColor = .darkText
        barButtonItem.title = title
        navigationItem.rightBarButtonItems = [barButtonItem]
    }
    
    public func setBiologerRightButtonItem(image: UIImage? = nil, title: String = "", action: @escaping () -> Void) {
        let image = image
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, action: action)
        barButtonItem.tintColor = .darkText
        barButtonItem.title = title
        navigationItem.rightBarButtonItems = [barButtonItem]
    }
    
    public func setBiologerRightButtonItem(image: UIImage, target: Any, action: Selector) {
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        barButtonItem.tintColor = .darkText
        navigationItem.rightBarButtonItems = [barButtonItem]
    }
    
    public func setBiologerRightButtonItem(image: UIImage? = nil, action: @escaping () -> Void) {
        let barButtonItem = UIBarButtonItem(image: image ?? UIImage(named: "back_arrow"), style: .plain, action: action)
        barButtonItem.tintColor = UIColor.darkText
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    public func setBiologerTitle(text: String, numberOfLines: Int = 0) {
        let titleLbl = UILabel()
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.darkText, .kern: 1.0, .font : UIFont.boldSystemFont(ofSize: navigationBarTitleSize)]
        let atributedString = NSAttributedString(string: text, attributes: attributes)
        titleLbl.attributedText = atributedString
        titleLbl.numberOfLines = numberOfLines
        titleLbl.textAlignment = .center
        titleLbl.sizeToFit()
        self.navigationItem.titleView = titleLbl
    }
    
        
    @objc open func hardPresent(_ viewControllerToPresent: UIViewController,
                                    animated: Bool,
                                    completion:  (() -> Void)?) {
        if presentedViewController != nil {
            dismiss(animated: true, completion: { [weak self] in
                self?.present(viewControllerToPresent,
                              animated: animated,
                              completion: completion)
            })
        } else {
            present(viewControllerToPresent,
                    animated: animated,
                    completion: completion)
        }
    }
    
    public func removeBackButtonItem() {
//        let image = UIImage(named: "")
//        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
//        barButtonItem.tintColor = .biologerGreenColor
//        navigationItem.leftBarButtonItems = [barButtonItem]
        self.navigationItem.hidesBackButton = true
    }

}

private var actionKey: Void?

extension UIBarButtonItem {

    private var _action: () -> () {
        get {
            return objc_getAssociatedObject(self, &actionKey) as! () -> ()
        }
        set {
            objc_setAssociatedObject(self, &actionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    convenience init(image: UIImage?, style: UIBarButtonItem.Style, action: @escaping () -> ()) {
        self.init(image: image ?? nil, style: style, target: nil, action: #selector(pressed))
        self.target = self
        self._action = action
    }

    @objc private func pressed(sender: UIBarButtonItem) {
        _action()
    }

}
