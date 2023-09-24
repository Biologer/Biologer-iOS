//
//  TaxonLoader.swift
//  Biologer
//
//  Created by Nikola Popovic on 20.9.23..
//

import Foundation
import SwiftCSV

public protocol TaxonLoader {
    func getTaxons(completion: @escaping (Error?) -> Void)
}

public final class CSVTaxonLoader: TaxonLoader {
    
    private let environmentStorage: EnvironmentStorage
    
    init(environmentStorage: EnvironmentStorage) {
        self.environmentStorage = environmentStorage
    }
    
    public func getTaxons(completion: @escaping (Error?) -> Void) {
        do {
            guard let url = getFileURL() else { return }
            let csvFile: CSV = try CSV<Named>(url: url)
            var currentPage = 1
            var arrayOfCSVModel = [CSVTaxonModel]()
            let lastPage = csvFile.rows.count
            
            print("Last page: \(lastPage)")
            
            try csvFile.enumerateAsDict({ [weak self] dic in
                guard let self = self else { return }
                print("Current page: \(currentPage)")
                let csvModel = self.mapToCSVTaxonModel(from: dic)
                arrayOfCSVModel.append(csvModel)
                currentPage += 1
        })
            
            self.save(with: arrayOfCSVModel)
            completion(nil)
        } catch let error {
            print("Error from reading CSV file: \(error)")
            completion(error)
        }
    }
    
    private func mapToCSVTaxonModel(from dic: [String: String]) -> CSVTaxonModel {
        let author = dic["Author"] ?? "Athor doesn't exist"
        return CSVTaxonModel(name: author)
    }
    
    func save(with csvModel: [CSVTaxonModel]) {
        let dbTaxons = csvModel.map { model in
            return DBTaxon(csvModel: model)
        }
        DispatchQueue.main.async {
            RealmManager.add(dbTaxons)
        }
    }
    
    private func getFileURL() -> URL? {
        if let env = environmentStorage.getEnvironment() {
            switch env.host {
            case serbiaHost:
                return CSVFileConstants.srbURL
            case croatiaHost:
                return CSVFileConstants.croURL
            case bosnianAndHerzegovinHost:
                return CSVFileConstants.bihURL
            case montenegroHost:
                return CSVFileConstants.mneURL
            case devHost:
                return CSVFileConstants.srbURL
            default:
                return nil
            }
        } else {
            return nil
        }
    }
}
