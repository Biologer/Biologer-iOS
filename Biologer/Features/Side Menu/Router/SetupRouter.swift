//
//  SetupRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import UIKit
import SwiftUI

public final class SetupRouter {
    
    private let navigationController: UINavigationController
    private let factory: SetupViewControllerFactory
    private let alertFactory: AlertViewControllerFactory
    private let swiftUICommonFactory: CommonViewControllerFactory
    private let taxonPaginationStorage: TaxonsPaginationInfoStorage
    private let imageLicenseStorage: LicenseStorage
    private let dataLicenseStorage: LicenseStorage
    private let settingsStorage: SettingsStorage
    
    public var onSideMenuTapped: Observer<Void>?
    public var onStartDownloadTaxon: Observer<Void>?
    
    init(navigationController: UINavigationController,
         factory: SetupViewControllerFactory,
         swiftUICommonFactory: CommonViewControllerFactory,
         alertFactory: AlertViewControllerFactory,
         taxonPaginationStorage: TaxonsPaginationInfoStorage,
         imageLicenseStorage: LicenseStorage,
         dataLicenseStorage: LicenseStorage,
         settingsStorage: SettingsStorage) {
        self.navigationController = navigationController
        self.factory = factory
        self.swiftUICommonFactory = swiftUICommonFactory
        self.taxonPaginationStorage = taxonPaginationStorage
        self.alertFactory = alertFactory
        self.dataLicenseStorage = dataLicenseStorage
        self.imageLicenseStorage = imageLicenseStorage
        self.settingsStorage = settingsStorage
    }
    
    // MARK: - Public Functions
    
    public func start() {
        showSetupScreen()
    }
    
    // MARK: - Private Functions
    
    private func showSetupScreen() {
        let vc = factory.makeSetupScreen(onItemTapped: { [weak self] item in
            guard let self = self else { return }
            switch item.type {
            case .chooseGropups, .observationEntry, .adultByDefault, .englishNames:
                break
            case .projectName:
                self.showSetupProjectNameScreen()
            case .dataLicense:
                let dataLicense = self.dataLicenseStorage.getLicense() ?? CheckMarkItemMapper.getDataLicense()[0]
                self.showLicenseScreen(navBarTitle: "DataLicense.nav.title".localized,
                                       selectedItem: dataLicense,
                                       items: CheckMarkItemMapper.getDataLicense(),
                                       presentDatePicker: nil,
                                       onItemTapped: { [weak self] item in
                    self?.dataLicenseStorage.saveLicense(license: item)
                    self?.navigationController.popViewController(animated: true)
                })
            case .imageLicense:
                let imageLicense = self.imageLicenseStorage.getLicense() ?? CheckMarkItemMapper.getImageLicense()[0]
                self.showLicenseScreen(navBarTitle: "ImgLicense.nav.title".localized,
                                       selectedItem: imageLicense,
                                       items: CheckMarkItemMapper.getImageLicense(),
                                       presentDatePicker: nil,
                                       onItemTapped: { [weak self] item in
                    self?.imageLicenseStorage.saveLicense(license: item)
                    self?.navigationController.popViewController(animated: true)
                })
            case .downloadUpload:
                self.showSetupDownloadAndUploadScreen()
            case .downloadAllTaxa:
                self.onStartDownloadTaxon?(())
            case .resetAllTaxa:
                self.showDeleteTaxonFlow()
            }
        })
        vc.setBiologerBackBarButtonItem(image: UIImage(named: "side_menu_icon")!,
                                        action: {
            self.onSideMenuTapped?(())
        })
        vc.setBiologerTitle(text: "SideMenu.lb.setup".localized)
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
    
    private func showSetupProjectNameScreen() {
        let vc = factory.makeSetupProjectNameScreen(onCancelTapped: { _ in
            self.navigationController.dismiss(animated: true, completion: nil)
        },
                                                    onOkTapped: { _ in
            self.navigationController.dismiss(animated: true, completion: nil)
        })
        self.navigationController.present(vc, animated: true, completion: nil)
    }
    
    private func showSetupDownloadAndUploadScreen() {
        let vc = factory.makeSetupDownloadAndUploadScreen(onCancelTapped: { [weak self] _ in
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
    
    // MARK: - Delete Taxon Flow
    private func showDeleteTaxonFlow() {
        
        let dbTaxons = RealmManager.get(fromEntity: DBTaxon.self)
        if !dbTaxons.isEmpty {
            showTaxonDeleteScreen()
        } else {
            showTaxonsAreEmptyScreen()
        }
    }
    
    private func showTaxonDeleteScreen() {
        let yesOrNoVC = alertFactory.makeYesAndNoAlert(title: "Settings.lb.resetAllTaxa.yesOrNoAlert.title".localized,
                                                       onYesTapped: { [weak self] _ in
            guard let self = self else { return }
            self.deleteAllTaxonAndResetPagination()
            self.navigationController.dismiss(animated: true, completion: {
                let confirmAlertVC = self.alertFactory.makeConfirmationAlert(popUpType: .success,
                                                                             title: "Settings.lb.resetAllTaxa.confirmAlert.title".localized,
                                                                             description: "Settings.lb.resetAllTaxa.confirmAlert.description".localized,
                                                                             onTapp: { [weak self] _ in
                    self?.navigationController.dismiss(animated: true, completion: nil)
                })
                self.navigationController.present(confirmAlertVC, animated: true, completion: nil)
            })
        }, onNoTapped: { [weak self] _ in
            self?.navigationController.dismiss(animated: true, completion: nil)
        })
        self.navigationController.present(yesOrNoVC, animated: true, completion: nil)
    }
    
    private func showTaxonsAreEmptyScreen() {
        let confirmAlertVC = alertFactory.makeConfirmationAlert(popUpType: .info,
                                                                title: "Settings.lb.resetAllTaxa.confirmAlert.whentTaxonEmpty.title".localized,
                                                                description: "Settings.lb.resetAllTaxa.confirmAlert.whentTaxonEmpty.description".localized,
                                                                onTapp: { [weak self] _ in
            self?.navigationController.dismiss(animated: true, completion: nil)
        })
        self.navigationController.present(confirmAlertVC, animated: true, completion: nil)
    }
    
    private func deleteAllTaxonAndResetPagination() {
        RealmManager.delete(fromEntity: DBTaxon.self)
        if let settings = settingsStorage.getSettings() {
            settings.setLastTimeTaxonUpdate(with: Calendar.getLastTimeTaxonUpdate)
            settingsStorage.saveSettings(settings: settings)
        }
    }
}
