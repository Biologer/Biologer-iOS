//
//  AboutBiologerScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import Foundation

public final class AboutBiologerScreenViewModel: AboutBiologerScreenLoader {
    var currentDbDescription: String = "You are currently logged into a datebase:"
    var topImge: String = "biologer_logo_icon"
    var currentEnv: String = "https://dev.biologer.org"
    var descriptionOne: String = "Biologer is Open Source application issued under MIT license and designed to collect data on biodiversity in Eastern Europe."
    var descriptionTwo: String = "Biologer was developed with founds from Rufford Small Grands (project Nos.20507-B and 24652-B) and MAVA (project No. 15097)"
    var descriptionThree: String = "To find out more details aboud Biologer, visit our web page:"
    var envButtonTitle: String = "https://biologer.org"
    var version: String = "Version: 3.0.4"
    func envTapped() {}
}
