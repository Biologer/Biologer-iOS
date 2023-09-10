//
//  SetupViewControllerFactory.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import SwiftUI

public protocol SetupViewControllerFactory {
    func makeSetupScreen(onItemTapped: @escaping Observer<SetupItemViewModel>) -> UIViewController
    func makeSetupProjectNameScreen(onCancelTapped: @escaping Observer<Void>,
                                    onOkTapped: @escaping Observer<String>) -> UIViewController
    func makeSetupDownloadAndUploadScreen(onCancelTapped: @escaping Observer<Void>,
                                          onItemTapped: @escaping Observer<SetupRadioAndTitleModel>) -> UIViewController
}

public final class SwiftUISetupViewControllerFactory: SetupViewControllerFactory {
    
    private let settingsStorage: SettingsStorage
    
    init(settingsStorage: SettingsStorage) {
        self.settingsStorage = settingsStorage
    }
    
    public func makeSetupScreen(onItemTapped: @escaping Observer<SetupItemViewModel>) -> UIViewController {
        let viewModel = SetupScreenViewModel(settingsStorage: settingsStorage,
                                             onItemTapped: onItemTapped)
        let screen = SetupScreen(viewModel: viewModel)
        let vc = UIHostingController(rootView: screen)
        return vc
    }
    
    public func makeSetupProjectNameScreen(onCancelTapped: @escaping Observer<Void>,
                                           onOkTapped: @escaping Observer<String>) -> UIViewController {
        let viewModel = SetupProjectNameScreenViewModel(settingsStorage: settingsStorage,
                                                        onCancelTapped: onCancelTapped,
                                                        onOkTapped: onOkTapped)
        let screen = SetupProjectNameScreen(viewModel: viewModel)
        let controller = UIHostingController(rootView: screen)
        controller.view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        return controller
    }
    
    public func makeSetupDownloadAndUploadScreen(onCancelTapped: @escaping Observer<Void>,
                                                 onItemTapped: @escaping Observer<SetupRadioAndTitleModel>) -> UIViewController {
        let viewModel = SetupDownloadAndUploadScreenViewModel(settingsStorage: settingsStorage,
                                                              onCancelTapped: onCancelTapped,
                                                              onItemTapped: onItemTapped)
        let screen = SetupDownloadAndUploadScreen(viewModel: viewModel)
        let controller = UIHostingController(rootView: screen)
        controller.view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        return controller
    }
}
