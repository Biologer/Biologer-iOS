//
//  NewFindingDevStageScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 3.10.21..
//

import Foundation

public protocol NewTaxonDevStageScreenViewModelDelegate {
    func updateDevStage(devStageViewModel: DevStageViewModel)
}

public final class NewFindingDevStageScreenViewModel: ObservableObject {
    
    public private(set) var stages: [DevStageViewModel]
    private let delegate: NewTaxonDevStageScreenViewModelDelegate?
    private let onDone: Observer<Void>
    
    init(stages: [DevStageViewModel],
         delegate: NewTaxonDevStageScreenViewModelDelegate?,
         onDone: @escaping Observer<Void>) {
        self.stages = stages
        self.delegate = delegate
        self.onDone = onDone
    }
    
    public func stageSelect(stage: DevStageViewModel) {
        delegate?.updateDevStage(devStageViewModel: stage)
        onDone(())
    }
    
    public func dissmisScreen() {
        onDone(())
    }
}
