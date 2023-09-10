//
//  ListOfFindingsScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.6.21..
//

import Foundation

public enum FindingsScreenPreviewType {
    case regular([Finding])
    case iregular(String)
}

public final class ListOfFindingsScreenViewModel: ListOfFindingsScreenLoader, ObservableObject {
    var onDeleteFindingTapped: Observer<Finding>
    var onNewItemTapped: Observer<Void>
    var onItemTapped: Observer<Finding>
    
    @Published var preview: FindingsScreenPreviewType = .iregular("ListOfFindings.noFindings.title".localized)
    var findings = [Finding]()
    
    init(onNewItemTapped: @escaping Observer<Void>,
         onItemTapped: @escaping Observer<Finding>,
         onDeleteFindingTapped: @escaping Observer<Finding>) {
        self.onNewItemTapped = onNewItemTapped
        self.onItemTapped = onItemTapped
        self.onDeleteFindingTapped = onDeleteFindingTapped
    }
    
    func getData() {
        let result = RealmManager.get(fromEntity: DBFinding.self)
        
        if let findings = ListOfFindingsMapper.getFinding(dbFindings: result) {
            self.findings = findings
            preview = .regular(findings)
        } else {
            preview = .iregular("ListOfFindings.noFindings.title".localized)
        }
    }
}

extension ListOfFindingsScreenViewModel: DeleteFindingsScreenViewModelDelegate {
    public func delete(finding: Finding?) {
        if let finding = finding {
            if let getFinding = RealmManager.get(fromEntity: DBFinding.self, primaryKey: finding.id) {
                RealmManager.delete(getFinding)
                getData()
            } else {
                print("This item doesn't exist with primary key: \(finding.id)")
            }
        } else {
            RealmManager.delete(fromEntity: DBFinding.self)
            getData()
        }
    }
}
