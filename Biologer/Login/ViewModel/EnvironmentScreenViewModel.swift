//
//  EnvironmentScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.4.21..
//

import Foundation

public protocol EnvironmentScreenViewModelProtocol {
    func getEnvironment(environmentViewModel: EnvironmentViewModel)
}

public final class EnvironmentScreenViewModel: EnvironmentScreenLoader {
    public let title: String
    public let environmentsViewModel: [EnvironmentViewModel]
    private let delegate: EnvironmentScreenViewModelProtocol?
    private let onSelectedEnvironment: Observer<Void>
    
    
    init(title: String,
         environmentsViewModel: [EnvironmentViewModel],
         delegate: EnvironmentScreenViewModelProtocol? = nil,
         onSelectedEnvironment: @escaping Observer<Void>) {
        self.title = title
        self.environmentsViewModel = environmentsViewModel
        self.delegate = delegate
        self.onSelectedEnvironment = onSelectedEnvironment
    }
    
    public func selectedEnvironment(envViewModel: EnvironmentViewModel) {
        delegate?.getEnvironment(environmentViewModel: envViewModel)
        onSelectedEnvironment(())
    }
}
