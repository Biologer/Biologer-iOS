//
//  SetupDownloadAndUploadMapper.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import Foundation

public final class SetupDownloadAndUploadMapper {
    public static func getItems(settingsStorage: SettingsStorage) -> [SetupRadioAndTitleModel] {
        getItems(settings: settingsStorage.getSettings() ?? Settings())
    }

    public static func getItems(settings: Settings) -> [SetupRadioAndTitleModel] {
        return [SetupRadioAndTitleModel(isSelected: settings.autoDownloadTaxon[0].isSelected,
                                        title: "DownloadAndUpload.nav.onlyWifi".localized,
                                        type: .onlyWiFi),
                SetupRadioAndTitleModel(isSelected: settings.autoDownloadTaxon[1].isSelected,
                                        title: "DownloadAndUpload.nav.onAnyNetwork".localized,
                                        type: .onAnyNetwork),
                SetupRadioAndTitleModel(isSelected: settings.autoDownloadTaxon[2].isSelected,
                                        title: "DownloadAndUpload.nav.alwaysAsk".localized,
                                        type: .alwaysAskUser)]
    }
}
