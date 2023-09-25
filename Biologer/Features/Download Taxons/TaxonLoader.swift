//
//  TaxonLoader.swift
//  Biologer
//
//  Created by Nikola Popovic on 20.9.23..
//

import Foundation
import SwiftCSV

public protocol TaxonLoader {
    typealias Result = Swift.Result<[CSVTaxonModel], Error>
    func getTaxons(fromFile url: URL, completion: (Result) -> Void)
}

public final class CSVTaxonLoader: TaxonLoader {
    
    public typealias Result = Swift.Result<[CSVTaxonModel], Error>
    
    private let environmentStorage: EnvironmentStorage
    
    init(environmentStorage: EnvironmentStorage) {
        self.environmentStorage = environmentStorage
    }
    
    public func getTaxons(fromFile url: URL,
                          completion: (Result) -> Void) {
        do {
            let csvFile: CSV = try CSV<Named>(url: url)
            var currentPage = 1
            var arrayOfCSVModel = [CSVTaxonModel]()
            
            try csvFile.enumerateAsDict({ [weak self] dic in
                guard let self = self else { return }
                print("Current page: \(currentPage)")
                let csvModel = self.mapToCSVTaxonModel(from: dic)
                arrayOfCSVModel.append(csvModel)
                currentPage += 1
        })
            completion(.success(arrayOfCSVModel))
        } catch let error {
            print("Error from reading CSV file: \(error)")
            completion(.failure(error))
        }
    }
    
    private func mapToCSVTaxonModel(from dic: [String: String]) -> CSVTaxonModel {
        let author = dic["Author"] ?? "Athor doesn't exist"
        return CSVTaxonModel(name: author)
    }
}
