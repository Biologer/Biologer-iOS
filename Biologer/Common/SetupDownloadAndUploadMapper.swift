//
//  SetupDownloadAndUploadMapper.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import Foundation

public final class SetupDownloadAndUploadMapper {
    public static func getItems() -> [SetupRadioAndTitleModel] {
        return [SetupRadioAndTitleModel(isSelected: false, title: "DownloadAndUpload.nav.onlyWifi".localized),
                SetupRadioAndTitleModel(isSelected: false, title: "DownloadAndUpload.nav.onAnyNetwork".localized),
                SetupRadioAndTitleModel(isSelected: true, title: "DownloadAndUpload.nav.alwaysAsk".localized)]
    }
}
