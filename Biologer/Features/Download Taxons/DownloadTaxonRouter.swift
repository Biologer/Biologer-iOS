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
    private let taxonUseCase: TaxonsSavingUseCase
    private let envvironmentStorage: EnvironmentStorage
    
    private var biologerProgressBarDelegate: BiologerProgressBarDelegate?
    public private (set) var sholdPresentConfirmationWhenAllTaxonAleadyDownloaded = true
    
    lazy var onLoading: Observer<Bool> = { [weak self] isLoading in
        guard let self = self else { return }
        if isLoading {
            let loader  = self.swiftUICommonFactory.createBlockingProgress()
            self.navigationController.present(loader, animated: false, completion: nil)
        } else {
            self.navigationController.dismiss(animated: false, completion: nil)
        }
    }
    
    private func onLoading(with: Bool, completion: @escaping () -> Void) {
        if with {
            let loader  = self.swiftUICommonFactory.createBlockingProgress()
            self.navigationController.present(loader, animated: false, completion: completion)
        } else {
            self.navigationController.dismiss(animated: false, completion: completion)
        }
    }
    
    init(alertFactory: AlertViewControllerFactory,
         swiftUICommonFactory: CommonViewControllerFactory,
         taxonUseCase: TaxonsSavingUseCase,
         envvironmentStorage: EnvironmentStorage) {
        self.alertFactory = alertFactory
        self.swiftUICommonFactory = swiftUICommonFactory
        self.taxonUseCase = taxonUseCase
        self.envvironmentStorage = envvironmentStorage
    }
    
    public func start(navigationController: UINavigationController,
                      sholdPresentConfirmationWhenAllTaxonAleadyDownloaded: Bool = true) {
        self.navigationController = navigationController
        self.sholdPresentConfirmationWhenAllTaxonAleadyDownloaded = sholdPresentConfirmationWhenAllTaxonAleadyDownloaded
        saveAndDownloadTaxonIfNeeded()
    }
    
    // MARK: - Private Functions
    
    private func saveAndDownloadTaxonIfNeeded() {
        let taxonsDB = RealmManager.get(fromEntity: DBTaxon.self)
        if taxonsDB.isEmpty {
            saveTaxonInDataBase()
        } else {
            onLoading((true))
            downloadTaxonAndSaveToDataBase()
        }
    }
    
    private func saveTaxonInDataBase() {
        onLoading(with: true) { [weak self] in
            guard let self = self else { return }
            self.taxonUseCase.saveCSVTaxons(bySelected: self.envvironmentStorage,
                                            forceDownloadEnv: self.sholdPresentConfirmationWhenAllTaxonAleadyDownloaded) { [weak self] error in
                if let error = error {
                    self?.onLoading((false))
                    self?.showConfirmationAlert(popUpType: .error,
                                                title: error.title,
                                                description: error.description)
                } else {
                    self?.downloadTaxonAndSaveToDataBase()
                }
            }
        }
    }
    
    private func downloadTaxonAndSaveToDataBase() {
        taxonUseCase.updateTaxonsIfNeeded(completion: { [weak self] result in
            guard let self = self else { return }
            self.onLoading((false))
            switch result {
            case .success(let response):
                print("Taxons count from API: \(response.meta.total)")
                if self.sholdPresentConfirmationWhenAllTaxonAleadyDownloaded {
                    self.showConfirmationAlert(popUpType: .success,
                                               title: "DownloadAndUpload.popUp.success.title".localized,
                                               description: "DownloadAndUpload.popUp.success.description".localized)
                }
            case .failure(let error):
                self.showConfirmationAlert(popUpType: .error,
                                           title: error.title,
                                           description: error.description)
            }
        })
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
