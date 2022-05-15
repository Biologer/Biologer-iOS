//
//  DeleteFindingsScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 7.10.21..
//

import Foundation

public protocol DeleteFindingsScreenViewModelDelegate {
    func delete(finding: Finding?)
}

public final class DeleteFindingsScreenViewModel: ObservableObject {
    let title: String = "ListOfFindings.deleteScreen.title".localized
    let deleteSelectedTitle: String = "ListOfFindings.deleteScreen.lb.selectedTitle".localized
    let deleteAllFindings: String = "ListOfFindings.deleteScreen.lb.allTitle".localized
    let buttonDelete: String = "ListOfFindings.deleteScreen.btn.delete".localized
    let buttonCancel: String = "ListOfFindings.deleteScreen.btn.cancel".localized
    @Published var isAllSelected: Bool = false
    
    private let onDeleteDone: Observer<Void>
    private let selectedFinding: Finding
    public var delegate: DeleteFindingsScreenViewModelDelegate?
    
    init(selectedFinding: Finding,
         onDeleteDone: @escaping Observer<Void>) {
        self.selectedFinding = selectedFinding
        self.onDeleteDone = onDeleteDone
    }
    
    public func deleteTapped() {
        delegate?.delete(finding: isAllSelected ? nil : selectedFinding)
        onDeleteDone(())
    }
    
    public func cancelTapped() {
        onDeleteDone(())
    }
    
    public func allSelected(value: Bool) {
        isAllSelected = value
    }
}
