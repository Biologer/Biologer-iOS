//
//  TaxonsPaginationInfoStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 7.11.21..
//

import Foundation

public protocol TaxonsPaginationInfoStorage {
    func getPaginationInfo() -> TaxonsPaginationInfo?
    func savePagination(paginationInfo: TaxonsPaginationInfo)
    func delete()
}
