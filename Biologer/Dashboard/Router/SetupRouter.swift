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
        let vc = factory.makeSetupScreen(onItemTapped: { [weak self] item in
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
                self?.showSetupProjectNameScreen(projectName: "Some project")
            case .dataLicense:
                let dataLicense = CheckMarkItemMapper.getDataLicense()
                self?.showLicenseScreen(navBarTitle: "DataLicense.nav.title".localized,
                                       selectedItem: dataLicense[0],
                                       items: dataLicense,
                                       presentDatePicker: nil,
                                       onItemTapped: { [weak self] item in
                                            self?.navigationController.popViewController(animated: true)
                                       })
            case .imageLicense:
                let imageLicense = CheckMarkItemMapper.getImageLicense()
                self?.showLicenseScreen(navBarTitle: "ImgLicense.nav.title".localized,
                                       selectedItem: imageLicense[0],
                                       items: imageLicense,
                                       presentDatePicker: nil,
                                       onItemTapped: { [weak self] item in
                                            self?.navigationController.popViewController(animated: true)
                                       })
            case .downloadUpload:
                self?.showSetupDownloadAndUploadScreen(items: SetupDownloadAndUploadMapper.getItems())
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
                                   selectedItem: CheckMarkItem,
                                   items: [CheckMarkItem],
                                   presentDatePicker: CheckMarkScreenDelegate?,
                                   onItemTapped: @escaping Observer<CheckMarkItem>) {
        
        let dataLicenseViewController = swiftUICommonFactory.makeLicenseScreen(items: items,
                                                                  selectedItem: selectedItem,
                                                                  delegate: presentDatePicker,
                                                                  onItemTapped: onItemTapped)
        dataLicenseViewController.setBiologerBackBarButtonItem(target: self, action: #selector(goBack))
        dataLicenseViewController.setBiologerTitle(text: navBarTitle)
        self.navigationController.pushViewController(dataLicenseViewController, animated: true)
    }
    
    private func showSetupProjectNameScreen(projectName: String) {
        let vc = factory.makeSetupProjectNameScreen(projectName: projectName,
                                                    onCancelTapped: { _ in
                                                        self.navigationController.dismiss(animated: true, completion: nil)
                                                    },
                                                    onOkTapped: { newProjectName in
                                                        self.navigationController.dismiss(animated: true, completion: nil)
                                                    })
        self.navigationController.present(vc, animated: true, completion: nil)
    }
    
    private func showSetupDownloadAndUploadScreen(items: [SetupRadioAndTitleModel]) {
        let vc = factory.makeSetupDownloadAndUploadScreen(items: items,
                                                          onCancelTapped: { [weak self] _ in
                                                                self?.navigationController.dismiss(animated: true, completion: nil)
                                                          },
                                                          onItemTapped: { [weak self] item in
                                                                self?.navigationController.dismiss(animated: true, completion: nil)
                                                          })
        self.navigationController.present(vc, animated: true, completion: nil)
    }
    
    @objc func goBack() {
        navigationController.popViewController(animated: true)
    }
}
