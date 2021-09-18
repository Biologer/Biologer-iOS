//
//  SetupRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import UIKit

public final class SetupRouter {
    
    private let navigationController: UINavigationController
    private let factory: SetupViewControllerFactory
    private let swiftUICommonFactory: CommonViewControllerFactory
    public var onSideMenuTapped: Observer<Void>?
    
    init(navigationController: UINavigationController,
         factory: SetupViewControllerFactory,
         swiftUICommonFactory: CommonViewControllerFactory) {
        self.navigationController = navigationController
        self.factory = factory
        self.swiftUICommonFactory = swiftUICommonFactory
    }
    
    public func start() {
        showSetupScreen()
    }
    
    // MARK: - Private Functions
    private func showSetupScreen() {
        let vc = factory.makeSetupScreen(onItemTapped: { item in
            switch item.type {
            case .chooseGropups:
                print("Choosen groups tapped")
            case .englishNames:
                print("English names tapped")
            case .adultByDefault:
                print("Adult default tapped")
            case .observationEntry:
                print("Observation entry")
            case .projectName:
                print("Project name tapped")
            case .dataLicense:
                print("Data license tapped")
            case .imageLicense:
                print("Image license tapped")
                let imageLicense = CheckMarkItemMapper.getImageLicense()
                self.showLicenseScreen(navBarTitle: "IMAGE LICENSE",
                                       selectedDataLicense: imageLicense[0],
                                       dataLicenses: imageLicense,
                                       presentDatePicker: nil)
            case .downloadUpload:
                print("Download and upload tapped")
            case .downloadAllTaxa:
                print("Download all taxa")
            }
        })
        vc.setBiologerBackBarButtonItem(image: UIImage(named: "side_menu_icon")!,
                                        action: {
                                            self.onSideMenuTapped?(())
                                        })
        self.navigationController.setViewControllers([vc], animated: false)
    }
    
    private func showLicenseScreen(navBarTitle: String,
                                   selectedDataLicense: CheckMarkItem,
                                   dataLicenses: [CheckMarkItem],
                                   presentDatePicker: DataLicenseScreenDelegate?) {
        
        let dataLicenseViewController = swiftUICommonFactory.makeLicenseScreen(dataLicenses: dataLicenses,
                                                                  selectedDataLicense: selectedDataLicense,
                                                                  delegate: presentDatePicker) { [weak self] dataLicenses in
            self?.navigationController.popViewController(animated: true)
        }
        dataLicenseViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        dataLicenseViewController.setBiologerTitle(text: navBarTitle)
        self.navigationController.pushViewController(dataLicenseViewController, animated: true)
    }
    
    @objc func goBack() {
        navigationController.popViewController(animated: true)
    }
}
