//
//  EnvironmentScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.4.21..
//

import Foundation
import Combine

public protocol EnvironmentScreenViewModelProtocol {
    func getEnvironment(environmentViewModel: EnvironmentViewModel)
}

public final class EnvironmentScreenViewModel: ObservableObject {
    public let title: String = "SELECT ENVIRONMENT"
    @Published public var environmentsViewModel: [EnvironmentViewModel]
    
    private let delegate: EnvironmentScreenViewModelProtocol?
    private let onSelectedEnvironment: Observer<Void>
    
    
    init(environmentsViewModel: [EnvironmentViewModel],
        selectedViewModel: EnvironmentViewModel,
         delegate: EnvironmentScreenViewModelProtocol? = nil,
         onSelectedEnvironment: @escaping Observer<Void>) {
        self.environmentsViewModel = environmentsViewModel
        self.delegate = delegate
        self.onSelectedEnvironment = onSelectedEnvironment
        updateSelectedViewModel(envViewModel: selectedViewModel)
    }
    
    public func selectedEnvironment(envViewModel: EnvironmentViewModel) {
        updateSelectedViewModel(envViewModel: envViewModel)
        delegate?.getEnvironment(environmentViewModel: envViewModel)
        onSelectedEnvironment(())
    }
    
    public func updateSelectedViewModel(envViewModel: EnvironmentViewModel) {

        for (index, env) in environmentsViewModel.enumerated() {
            if env.id == envViewModel.id {
                environmentsViewModel[index].changeIsSelected(value: true)
            } else {
                environmentsViewModel[index].changeIsSelected(value: false)
            }
        }
    }
}
