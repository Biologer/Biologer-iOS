//
//  TaxonsPaginationInfo.swift
//  Biologer
//
//  Created by Nikola Popovic on 7.11.21..
//

import Foundation

public final class TaxonsPaginationInfo: Codable {
    public let currentPage: Int
    public let perPage: Int
    public let lastPage: Int
    public let total: Int
    public var lastTimeUpdate: Int64 = 0
    
    public var isAllTaxonDownloaded: Bool {
        return currentPage == lastPage
    }
    
    init(currentPage: Int,
         perPage: Int = APIConstants.taxonsPerPage,
         lastPage: Int,
         total: Int) {
        self.currentPage = currentPage
        self.perPage = perPage
        self.lastPage = lastPage
        self.total = total
    }
    
    public func set(lastTimeUpdate: Int64) {
        self.lastTimeUpdate = lastTimeUpdate
    }
}
