//
//  CSVTaxonsUseCase.swift
//  Biologer
//
//  Created by Nikola Popovic on 25.9.23..
//

import Foundation

protocol TaxonsSavingUseCase {
    func saveCSVTaxons(bySelected envStorage: EnvironmentStorage,
                       with settingsStorage: SettingsStorage,
                       completion: @escaping (APIError?) -> Void)
}

public final class CSVTaxonsUseCase: TaxonsSavingUseCase {
    
    private let taxonLoader: TaxonLoader
    private let taxonDBManager: TaxonDBManager
    
    init(taxonLoader: TaxonLoader,
         taxonDBManager: TaxonDBManager) {
        self.taxonLoader = taxonLoader
        self.taxonDBManager = taxonDBManager
    }
    
    func saveCSVTaxons(bySelected envStorage: EnvironmentStorage,
                       with settingsStorage: SettingsStorage,
                       completion: @escaping (APIError?) -> Void) {
        
        guard let selectedEnv = envStorage.getEnvironment(),
                    let settings = settingsStorage.getSettings() else {
            completion(APIError(description: ErrorConstant.environmentNotSelected))
            return
        }
        
        if let savedTaxonEnv = settings.taxonCSVFileEnv {
            if selectedEnv.getEnvForTaxons == savedTaxonEnv {
                completion(nil)
            } else {

                guard let taxonFileURL = selectedEnv.getCSVFile else {
                    completion(APIError(description: ErrorConstant.parsingErrorConstant))
                    return
                }
                
                taxonDBManager.deleteAll()
                removeTaxaonsInfo(from: settingsStorage)
                saveTaxonsAndSettings(withFile: taxonFileURL,
                                      env: selectedEnv,
                                      settingsStorage: settingsStorage,
                                      completion: completion)
            }
        } else {
            guard let taxonFileURL = selectedEnv.getCSVFile else {
                completion(APIError(description: ErrorConstant.parsingErrorConstant))
                return
            }
            
            saveTaxonsAndSettings(withFile: taxonFileURL,
                                  env: selectedEnv,
                                  settingsStorage: settingsStorage,
                                  completion: completion)
        }
    }
    
    // MARK: - Private Functions
    
    private func removeTaxaonsInfo(from settingsStorage: SettingsStorage) {
        if let settings = settingsStorage.getSettings() {
            settings.setTaxonCSVFileEnv(with: nil)
            settings.setLastTimeTaxonUpdate(with: 0)
            settingsStorage.saveSettings(settings: settings)
        }
        
    }
    
    private func save(settingsStorage: SettingsStorage,
                      byEnvironment: String,
                      withTimeStamp: Int64) {
        if let settings = settingsStorage.getSettings() {
            settings.setTaxonCSVFileEnv(with: byEnvironment)
            settings.setLastTimeTaxonUpdate(with: withTimeStamp)
            settingsStorage.saveSettings(settings: settings)
        }
    }
    
    private func saveTaxonsAndSettings(withFile url: URL,
                                       env: Environment,
                                       settingsStorage: SettingsStorage,
                                       completion: @escaping (APIError?) -> Void) {
        taxonLoader.getTaxons(fromFile: url) { [weak self] result in
            switch result {
            case .success(let response):
                self?.taxonDBManager.save(csvModels: response)
                self?.save(settingsStorage: settingsStorage,
                           byEnvironment: env.getEnvForTaxons,
                           withTimeStamp: 0)
                completion(nil)
            case .failure(let error):
                completion(APIError(description: error.localizedDescription))
            }
        }
    }
}
