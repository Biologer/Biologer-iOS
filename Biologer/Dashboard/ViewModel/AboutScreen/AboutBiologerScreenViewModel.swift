//
//  AboutBiologerScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import Foundation

// "https://dev.biologer.org"
// "Version: 3.0.4"

public final class AboutBiologerScreenViewModel: AboutBiologerScreenLoader {
    let currentDbDescription: String = "You are currently logged into a datebase:"
    let topImge: String = "biologer_logo_icon"
    let currentEnv: String
    let descriptionOne: String = "Biologer is Open Source application issued under MIT license and designed to collect data on biodiversity in Eastern Europe."
    let descriptionTwo: String = "Biologer was developed with founds from Rufford Small Grands (project Nos.20507-B and 24652-B) and MAVA (project No. 15097)"
    let descriptionThree: String = "To find out more details aboud Biologer, visit our web page:"
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
