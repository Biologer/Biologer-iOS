//
//  SetupDownloadAndUploadMapper.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import Foundation

public final class SetupDownloadAndUploadMapper {
    public static func getItems() -> [SetupRadioAndTitleModel] {
        return [SetupRadioAndTitleModel(isSelected: false, title: "Only on WiFi network"),
                SetupRadioAndTitleModel(isSelected: false, title: "On any network"),
                SetupRadioAndTitleModel(isSelected: true, title: "Always ask user")]
    }
}
