//
//  DownloadTaxonRouter.swift
//  Biologer
//
//  Created by Nikola Popovic on 26.11.21..
//

import UIKit
import SwiftUI

public final class DownloadTaxonRouter {
    
    private var navigationController: UINavigationController = UINavigationController()
    private let alertFactory: AlertViewControllerFactory
    private let swiftUICommonFactory: CommonViewControllerFactory
    private let settingsStorage: SettingsStorage
    private let taxonPaginationInfoStorage: TaxonsPaginationInfoStorage
    private let taxonServiceCordinator: TaxonServiceCoordinator
    
    private var biologerProgressBarDelegate: BiologerProgressBarDelegate?
    public private (set) var sholdPresentConfirmationWhenAllTaxonAleadyDownloaded = true
    
    init(alertFactory: AlertViewControllerFactory,
         swiftUICommonFactory: CommonViewControllerFactory,
         taxonServiceCordinator: TaxonServiceCoordinator,
         settingsStorage: SettingsStorage,
         taxonPaginationInfoStorage: TaxonsPaginationInfoStorage) {
        self.alertFactory = alertFactory
        self.swiftUICommonFactory = swiftUICommonFactory
        self.taxonServiceCordinator = taxonServiceCordinator
        self.settingsStorage = settingsStorage
        self.taxonPaginationInfoStorage = taxonPaginationInfoStorage
    }
    
    public func start(navigationController: UINavigationController,
                      sholdPresentConfirmationWhenAllTaxonAleadyDownloaded: Bool = true) {
        self.navigationController = navigationController
        self.sholdPresentConfirmationWhenAllTaxonAleadyDownloaded = sholdPresentConfirmationWhenAllTaxonAleadyDownloaded
        downloadTaxonIfNeeded()
    }
    
    // MARK: - Private Functions
    private func downloadTaxonIfNeeded() {
        let taxonsDB = RealmManager.get(fromEntity: DBTaxon.self)
        let checkInternetConnection = CheckInternetConnection.init()
        
        if !checkInternetConnection.isConnectedToInternet() {
            showConfirmationAlert(popUpType: .warning,
                                  title: "API.lb.error".localized,
                                  description: "Common.title.notConnectedToInternet".localized)
        } else {
            if taxonsDB.isEmpty { // is DB empty with taxon
                downloadTaxonByUserSettings()
            } else if let paginationInfo = taxonPaginationInfoStorage.getPaginationInfo(),
                      paginationInfo.isAllTaxonDownloaded { // is all taxon downloaded in previous download session
                downloadTaxonByUserSettings()
            } else {
                taxonServiceCordinator.checkingNewTaxons { [weak self] hasNewTaxons, error in
                    guard let self = self else { return }
                    guard error == nil else  {
                        self.showConfirmationAlert(popUpType: .error,
                                                   title: error!.title,
                                                   description: error!.description)
                        return
                    }
                    
                    if hasNewTaxons {
                        self.downloadTaxonByUserSettings()
                    } else {
                        if self.sholdPresentConfirmationWhenAllTaxonAleadyDownloaded {
                            self.showConfirmationAlert(popUpType: .success,
                                                       title: "DownloadAndUpload.popUp.success.title".localized,
                                                       description: "DownloadAndUpload.popUp.success.description".localized)
                        }
                    }
                }
            }
        }
    }
    
    private func downloadTaxonByUserSettings() {
        if let internetType = settingsStorage.getSettings()?.selectedAutoDownloadTaxon {
            switch internetType.type {
            case .onlyWiFi:
                downloadTaxonWhenWifiActive()
            case .onAnyNetwork:
                downloadTaxonOnAnyNetworkActive()
            case .alwaysAskUser:
                downloadTaxonAlwaysAskUserActive()
            }
        }
    }
    
    private func downloadTaxonWhenWifiActive() {
        let checkInternetConnection = CheckInternetConnection.init()
        if !checkInternetConnection.isConnectedToWiFi() {
            showYesOrNoAlert(title: "Common.title.notConnectedToWiFi".localized,
                                   onYesTapped: { [weak self] _ in
                                    self?.navigationController.dismiss(animated: true, completion: {
                                        self?.showDownloadTaxonsProgressBar()
                                    })
                                   },
                                   onNoTapped: { [weak self] _ in
                                    self?.navigationController.dismiss(animated: true, completion: nil)
                                   })
        } else {
            showDownloadTaxonsProgressBar()
        }
    }
    
    private func downloadTaxonOnAnyNetworkActive() {
        showDownloadTaxonsProgressBar()
    }
    
    private func downloadTaxonAlwaysAskUserActive() {
        let checkInternetConnection = CheckInternetConnection.init()
        showYesOrNoAlert(title: "DownloadTaxon.doYouWantDownload.title".localized,
                         onYesTapped: { [weak self] _ in
                            if !checkInternetConnection.isConnectedToWiFi() {
                                self?.showYesOrNoAlert(title: "Common.title.notConnectedToWiFi".localized,
                                                       onYesTapped: { [weak self] _ in
                                                        self?.navigationController.dismiss(animated: true, completion: {
                                                            self?.showDownloadTaxonsProgressBar()
                                                        })
                                                       },
                                                       onNoTapped: { [weak self] _ in
                                                        self?.navigationController.dismiss(animated: true, completion: nil)
                                                       })
                            } else {
                                self?.showDownloadTaxonsProgressBar()
                            }
                            self?.navigationController.dismiss(animated: true, completion: {
                                self?.downloadTaxonWhenWifiActive()
                            })
                         },
                         onNoTapped: { [weak self] _ in
                            self?.navigationController.dismiss(animated: true, completion: nil)
                         })
    }
    
    private func showDownloadTaxonsProgressBar() {
        var maxValue: Double = 10
        var currentValue: Double = 0
        if let paginationInfo = taxonPaginationInfoStorage.getPaginationInfo() {
            maxValue = Double(paginationInfo.lastPage)
            currentValue = Double(paginationInfo.currentPage)
        }
        showBilogerProgressBarScreen(maxValue: maxValue,
                                     currentValue: currentValue,
                                     onProgressAppeared: { [weak self] currentValue in
                                        
                                        self?.taxonServiceCordinator.resumeGetTaxon()
                                        self?.taxonServiceCordinator.getTaxons { currentValue, maxValue in
                                            self?.biologerProgressBarDelegate?.updateProgressBar(currentValue: currentValue, maxValue: maxValue)
                                            if currentValue == maxValue {
                                                self?.navigationController.dismiss(animated: true, completion: nil)
                                            }
                                        }
                                     },
                                     onCancelTapped: { [weak self] currentValue in
                                        self?.taxonServiceCordinator.stopGetTaxon()
                                        self?.navigationController.dismiss(animated: true, completion: nil)
                                     })
    }
    
    private func showBilogerProgressBarScreen(maxValue: Double,
                                              currentValue: Double = 0.0,
                                              onProgressAppeared: @escaping Observer<Double>,
                                              onCancelTapped: @escaping Observer<Double>) {
        let vc = swiftUICommonFactory.makeBiologerProgressBarView(maxValue: maxValue,
                                                     currentValue: currentValue,
                                                     onProgressAppeared: onProgressAppeared,
                                                     onCancelTapped: onCancelTapped)
        let viewController = vc as? UIHostingController<BiologerProgressBarScreen>
        biologerProgressBarDelegate = viewController?.rootView.viewModel
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.navigationController.present(vc, animated: true, completion: nil)
    }
    
    private func showYesOrNoAlert(title: String,
                                  onYesTapped: @escaping Observer<Void>,
                                  onNoTapped: @escaping Observer<Void>) {
        let vc = alertFactory.makeYesAndNoAlert(title: title, onYesTapped: onYesTapped, onNoTapped: onNoTapped)
        self.navigationController.present(vc, animated: true, completion: nil)
    }
    
    private func showConfirmationAlert(popUpType: PopUpType,
                                       title: String,
                                       description: String) {
        let vc = alertFactory.makeConfirmationAlert(popUpType: popUpType,
                                                    title: title,
                                                    description: description,
                                                    onTapp: { _ in
                                                        self.navigationController.dismiss(animated: true, completion: nil)
                                                    })
        self.navigationController.present(vc, animated: true, completion: nil)
    }
}
