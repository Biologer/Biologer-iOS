//
//  CSVTaxonsUseCase.swift
//  Biologer
//
//  Created by Nikola Popovic on 25.9.23..
//

import Foundation

protocol TaxonsSavingUseCase {
    typealias Result = Swift.Result<TaxonDataResponse, APIError>
    func saveCSVTaxons(bySelected envStorage: EnvironmentStorage,
                       forceDownloadEnv: Bool,
                       completion: @escaping (APIError?) -> Void)
    func updateTaxonsIfNeeded(completion: @escaping (Result) -> Void)
}

public final class CSVTaxonsUseCase: TaxonsSavingUseCase {
    
    public typealias Result = Swift.Result<TaxonDataResponse, APIError>
    
    private let taxonLoader: TaxonLoader
    private let taxonDBManager: TaxonDBManager
    private let taxonsService: TaxonService
    private let settingsStorage: SettingsStorage
    
    private var currentPageForDownload = 1
    private let perPage = 200
    
    init(taxonLoader: TaxonLoader,
         taxonDBManager: TaxonDBManager,
         taxonsService: TaxonService,
         settingsStorage: SettingsStorage) {
        self.taxonLoader = taxonLoader
        self.taxonDBManager = taxonDBManager
        self.taxonsService = taxonsService
        self.settingsStorage = settingsStorage
    }
    
    func saveCSVTaxons(bySelected envStorage: EnvironmentStorage,
                       forceDownloadEnv: Bool = false,
                       completion: @escaping (APIError?) -> Void) {
        
        guard let selectedEnv = envStorage.getEnvironment(),
              let settings = settingsStorage.getSettings() else {
            completion(APIError(description: ErrorConstant.environmentNotSelected))
            return
        }
        
        guard let taxonFileURL = selectedEnv.getCSVFile else {
            completion(APIError(description: ErrorConstant.parsingErrorConstant))
            return
        }
        
        if let savedTaxonEnv = settings.taxonCSVFileEnv {
            if selectedEnv.getEnvForTaxons == savedTaxonEnv && forceDownloadEnv == false {
                completion(nil)
            } else {
                taxonDBManager.deleteAll()
                removeTaxaonsInfo()
                saveTaxonsAndSettings(withFile: taxonFileURL,
                                      env: selectedEnv,
                                      completion: completion)
            }
        } else {
            saveTaxonsAndSettings(withFile: taxonFileURL,
                                  env: selectedEnv,
                                  completion: completion)
        }
    }
    
    public func updateTaxonsIfNeeded(completion: @escaping (Result) -> Void) {
        if let settings = settingsStorage.getSettings() {
            getTaxon(with: currentPageForDownload,
                     by: settings.lastTimeTaxonUpdate) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    if !response.data.isEmpty {
                        self.taxonDBManager.save(taxonResponse: response)
                        if self.currentPageForDownload == response.meta.last_page {
                            completion(.success(response))
                            self.save(timeStamp: Int64(Date().timeIntervalSince1970))
                        } else {
                            self.currentPageForDownload += 1
                            self.getTaxon(with: self.currentPageForDownload,
                                          by: settings.lastTimeTaxonUpdate,
                                          completion: completion)
                        }
                    } else {
                        completion(.success(response))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func getTaxon(with page: Int,
                          by timeStamp: Int64,
                          completion: @escaping (Result) -> Void) {
        taxonsService.getTaxons(currentPage: page,
                                perPage: perPage,
                                updatedAfter: timeStamp) { result in
            completion(result)
        }
    }
    
    // MARK: - Private Functions
    
    private func removeTaxaonsInfo() {
        if let settings = settingsStorage.getSettings() {
            settings.setTaxonCSVFileEnv(with: nil)
            settings.setLastTimeTaxonUpdate(with: 0)
            settingsStorage.saveSettings(settings: settings)
        }
    }
    
    private func save(timeStamp: Int64) {
        if let settings = settingsStorage.getSettings() {
            settings.setLastTimeTaxonUpdate(with: timeStamp)
            settingsStorage.saveSettings(settings: settings)
        }
    }
    
    private func save(taxonEnvironment: String) {
        if let settings = settingsStorage.getSettings() {
            settings.setTaxonCSVFileEnv(with: taxonEnvironment)
            settingsStorage.saveSettings(settings: settings)
        }
    }
    
    private func saveTaxonsAndSettings(withFile url: URL,
                                       env: Environment,
                                       completion: @escaping (APIError?) -> Void) {
        taxonLoader.getTaxons(fromFile: url) { [weak self] result in
            switch result {
            case .success(let response):
                self?.taxonDBManager.save(csvModels: response)
                self?.save(timeStamp: Calendar.getLastTimeTaxonUpdate)
                self?.save(taxonEnvironment: env.getEnvForTaxons)
                completion(nil)
            case .failure(let error):
                completion(APIError(description: error.localizedDescription))
            }
        }
    }
}
