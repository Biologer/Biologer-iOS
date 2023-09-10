//
//  BiologerNavigationViewController.swift
//  Biologer
//
//  Created by Nikola Popovic on 9.12.21..
//

import UIKit

public final class BiologerNavigationViewController: UINavigationController {
    
    var shouldBeTransparent = true {
        didSet (value) {
            setNavigationBarTransparent(value)
        }
    }
    
    init(shouldBeTransparent: Bool = true) {
        super.init(nibName: nil, bundle: nil)
        self.shouldBeTransparent = shouldBeTransparent
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTransparent(shouldBeTransparent)
    }
}

extension UINavigationController {
    
    public func setNavigationBarTransparent(_ transparent: Bool) {
        let appearance = getNavigationBarAppearance(transparent)
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }
    
    public func getNavigationBarAppearance(_ transparent: Bool) -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        transparent ? appearance.configureWithTransparentBackground() : appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = transparent ? .clear : .biologerGreenColor
        return appearance
    }
}
