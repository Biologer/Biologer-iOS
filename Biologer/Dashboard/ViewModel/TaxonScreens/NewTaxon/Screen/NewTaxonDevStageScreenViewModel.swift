//
//  NewTaxonDevStageScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 3.10.21..
//

import Foundation

public final class DevStageViewModel {
    var id = UUID()
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

public protocol NewTaxonDevStageScreenViewModelDelegate {
    func updateDevStage(devStageViewModel: DevStageViewModel)
}

public final class NewTaxonDevStageScreenViewModel: ObservableObject {
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
