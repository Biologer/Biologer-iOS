//
//  TaxonServiceCordinator.swift
//  Biologer
//
//  Created by Nikola Popovic on 7.11.21..
//

import Foundation

public final class TaxonServiceCoordinator {
    private let taxonService: TaxonService
    private let taxonPaginationInfo: TaxonsPaginationInfoStorage
    private var shouldExecuteCall: Bool = true
    
    init(taxonService: TaxonService, taxonPaginationInfo: TaxonsPaginationInfoStorage) {
        self.taxonService = taxonService
        self.taxonPaginationInfo = taxonPaginationInfo
    }
    
    public func stopGetTaxon() {
        shouldExecuteCall = false
    }
    
    public func resumeGetTaxon() {
        shouldExecuteCall = true
    }
    
    public func getTaxons(completion: @escaping (_ currentValue: Double, _ maxValue: Double) -> Void) {
        
        var page = 1
        var perPage = APIConstants.taxonsPerPage
        let lastTimeUpdate = taxonPaginationInfo.getLastReadFromFile() ?? 0
        
        if let paginationInfo = taxonPaginationInfo.getPaginationInfo() {
            page = paginationInfo.currentPage
            perPage = paginationInfo.perPage
        }
        
        taxonService.getTaxons(currentPage: page,
                               perPage: perPage,
                               updatedAfter: lastTimeUpdate,
                               completion: { [weak self] result in
                                guard let self = self else { return }
                                switch result {
                                case .failure(let error):
                                    print("Taxon Error: \(error.description)")
                                case .success(let response):
                                    //print("Taxon response: \(response)")
                                    self.saveToDB(taxonResponse: response)
                                    page += 1
                                    self.saveNextPagination(currentPage: page,
                                                            perPage: perPage,
                                                            lastPage: response.meta.last_page,
                                                            total: response.meta.total)
                                    
                                    completion(Double(page), Double(response.meta.last_page))
                                    
                                    if self.shouldExecuteCall {
                                        if page > response.meta.last_page {
                                            self.saveNextPagination(currentPage: 1,
                                                                    perPage: perPage,
                                                                    lastPage: response.meta.last_page,
                                                                    total: response.meta.total)
                                            
                                            self.taxonPaginationInfo.saveLastReadFromFile(Int64(Date().timeIntervalSince1970))
                                            
                                        } else {
                                            self.getTaxons(completion: completion)
                                        }
                                    }
                                }
                           })
    }
    
    public func checkingNewTaxons(completion: @escaping (_ hasNewTaxon: Bool, _ error: APIError?) -> Void) {
        let lastTimeUpdate: Int64 = taxonPaginationInfo.getLastReadFromFile() ?? 0 // If it is not saved, maybe something went wrong while reading file, so we download everything
        
        taxonService.getTaxons(currentPage: 1,
                               perPage: 1, // Could be 1. Just checking if there's anything new
                               updatedAfter: lastTimeUpdate) { result in
            switch result {
            case .failure(let error):
                completion(false, error)
            case .success(let response):
                if response.data.isEmpty {
                    completion(false, nil)
                } else {
                    completion(true, nil)
                }
            }
        }
    }
    
    private func saveNextPagination(currentPage: Int,
                                    perPage: Int,
                                    lastPage: Int,
                                    total: Int) {
        
        let nexPaginationInfo = TaxonsPaginationInfo(currentPage: currentPage,
                                                     perPage: perPage,
                                                     lastPage: lastPage,
                                                     total: total)
        
        self.taxonPaginationInfo.savePagination(paginationInfo: nexPaginationInfo)
    }
    
    private func saveToDB(taxonResponse: TaxonDataResponse) {
        DispatchQueue.main.async {
            taxonResponse.data.forEach({
                RealmManager.add(DBTaxon(taxon: $0))
            })
        }
    }
}
