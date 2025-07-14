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
        var lastTimeUpdate: Int64 = 0
        
        if let paginationInfo = taxonPaginationInfo.getPaginationInfo() {
            page = paginationInfo.currentPage
            perPage = paginationInfo.perPage
            lastTimeUpdate = paginationInfo.lastTimeUpdate
        }
        
        if page == 1 {
            RealmManager.delete(fromEntity: DBTaxon.self)
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
                                                            total: response.meta.total,
                                                            currentTime: 0)
                                    completion(Double(page), Double(response.meta.last_page))
                                    if self.shouldExecuteCall {
                                        if page > response.meta.last_page {
                                            self.saveNextPagination(currentPage: 1,
                                                                    perPage: perPage,
                                                                    lastPage: response.meta.last_page,
                                                                    total: response.meta.total,
                                                                    currentTime: Int64(Date().timeIntervalSince1970))
                                        } else {
                                            self.getTaxons(completion: completion)
                                        }
                                    }
                                }
                               })
    }
    
    public func checkingNewTaxons(completion: @escaping (_ hasNewTaxon: Bool, _ error: APIError?) -> Void) {
        
        if let paginationInfo = taxonPaginationInfo.getPaginationInfo() {
            let lastTimeUpdate: Int64 = paginationInfo.lastTimeUpdate
            taxonService.getTaxons(currentPage: 1,
                                   perPage: 10, // Could be 1. Just checking if there's anything new
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
    }
    
    private func saveNextPagination(currentPage: Int,
                                    perPage: Int,
                                    lastPage: Int,
                                    total: Int,
                                    currentTime: Int64) {
        let nexPaginationInfo = TaxonsPaginationInfo(currentPage: currentPage,
                                                     perPage: perPage,
                                                     lastPage: lastPage,
                                                     total: total)
        nexPaginationInfo.set(lastTimeUpdate: currentTime)
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
