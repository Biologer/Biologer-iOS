//
//  SetupViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import SwiftUI

public protocol SetupViewControllerFactory {
    func makeSetupScreen(onItemTapped: @escaping Observer<SetupItemViewModel>) -> UIViewController
}

public final class SwiftUISetupViewControllerFactory: SetupViewControllerFactory {
    
    public func makeSetupScreen(onItemTapped: @escaping Observer<SetupItemViewModel>) -> UIViewController {
        let viewModel = SetupScreenViewModel(sections: SetupDataMapper.getSetupData(),
                                             onItemTapped: onItemTapped)
        let screen = SetupScreen(viewModel: viewModel)
        let vc = UIHostingController(rootView: screen)
        return vc
    }
}
