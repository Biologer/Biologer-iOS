//
//  TaxonsPaginationInfoStorage.swift
//  Biologer
//
//  Created by Nikola Popovic on 7.11.21..
//

import Foundation

public protocol TaxonsPaginationInfoStorage {
    func getPaginationInfo() -> TaxonsPaginationInfo?
    func getLastReadFromFile() -> Int64?
    func savePagination(paginationInfo: TaxonsPaginationInfo)
    func saveLastReadFromFile(_ date: Int64)
    func delete()
}
