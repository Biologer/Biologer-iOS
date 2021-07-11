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
    public let title: String = "SELECT ENVIRONMENT"
    public let environmentsViewModel: [EnvironmentViewModel] = [
        EnvironmentViewModel(title: "Serbia", image: "serbia_flag", url: "www.serbia.com", isSelected: false),
        EnvironmentViewModel(title: "Croatia", image: "croatia_flag", url: "www.croatia.com", isSelected: false),
        EnvironmentViewModel(title: "Bosnia and Herzegovina", image: "bosnia_flag_icon", url: "www.bosniaandherzegovina.com", isSelected: false),
        EnvironmentViewModel(title: "For Developers", image: "hammer_icon", url: "www.bosniaandherzegovina.com", isSelected: false)
    ]
    
    private let delegate: EnvironmentScreenViewModelProtocol?
    private let onSelectedEnvironment: Observer<Void>
    
    
    init(selectedViewModel: EnvironmentViewModel,
         delegate: EnvironmentScreenViewModelProtocol? = nil,
         onSelectedEnvironment: @escaping Observer<Void>) {
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
        environmentsViewModel.forEach({
            if $0.id == envViewModel.id {
                $0.isSelected = true
            } else {
                $0.isSelected = false
            }
        })
    }
}
