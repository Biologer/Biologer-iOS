//
//  AboutBiologerScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import Foundation

public final class AboutBiologerScreenViewModel: AboutBiologerScreenLoader {
    let currentDbDescription: String = "AboutBiologer.lb.currentlyDB".localized
    let topImge: String = "biologer_logo_icon"
    let currentEnv: String
    let descriptionOne: String = "AboutBiologer.lb.desc.one".localized
    let descriptionTwo: String = "AboutBiologer.lb.desc.two".localized
    let descriptionThree: String = "AboutBiologer.lb.toFingMoreDetails".localized
    let envButtonTitle: String
    let version: String
    private let onEnvTapped: Observer<String>
    
    init(currentEnv: String,
         version: String,
         onEnvTapped: @escaping Observer<String>) {
        self.currentEnv = currentEnv
        self.envButtonTitle = currentEnv
        self.version = version
        self.onEnvTapped = onEnvTapped
    }
    
    func envTapped() {
        onEnvTapped((currentEnv))
    }
}
