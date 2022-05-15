//
//  SetupDownloadAndUploadMapper.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import Foundation

public final class SetupDownloadAndUploadMapper {
    public static func getItems(settingsStorage: SettingsStorage) -> [SetupRadioAndTitleModel] {
        return [SetupRadioAndTitleModel(isSelected: settingsStorage.getSettings()?.autoDownloadTaxon[0].isSelected ?? false,
                                        title: "DownloadAndUpload.nav.onlyWifi".localized,
                                        type: .onlyWiFi),
                SetupRadioAndTitleModel(isSelected: settingsStorage.getSettings()?.autoDownloadTaxon[1].isSelected ?? false,
                                        title: "DownloadAndUpload.nav.onAnyNetwork".localized,
                                        type: .onAnyNetwork),
                SetupRadioAndTitleModel(isSelected: settingsStorage.getSettings()?.autoDownloadTaxon[2].isSelected ?? true,
                                        title: "DownloadAndUpload.nav.alwaysAsk".localized,
                                        type: .alwaysAskUser)]
    }
}
