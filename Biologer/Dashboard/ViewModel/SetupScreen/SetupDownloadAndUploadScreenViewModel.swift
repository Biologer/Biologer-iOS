//
//  SetupDownloadAndUploadScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import Foundation

public final class SetupRadioAndTitleModel: Identifiable, ObservableObject {
    public let id = UUID()
    @Published public var isSelected: Bool
    public let title: String
    
    init(isSelected: Bool, title: String) {
        self.isSelected = isSelected
        self.title = title
    }
}

public final class SetupDownloadAndUploadScreenViewModel: ObservableObject {
    @Published var items: [SetupRadioAndTitleModel]
    public let cancelButtonTitle = "Common.btn.cancel".localized
    public let title = "DownloadAndUpload.nav.title".localized
    private let onCancelTapped: Observer<Void>
    private let onItemTapped: Observer<SetupRadioAndTitleModel>
    
    init(items: [SetupRadioAndTitleModel],
         onCancelTapped: @escaping Observer<Void>,
         onItemTapped: @escaping Observer<SetupRadioAndTitleModel>) {
        self.items = items
        self.onCancelTapped = onCancelTapped
        self.onItemTapped = onItemTapped
    }
    
    public func itemTapped(selectedIndex: Int) {
        items.forEach { $0.isSelected = false }
        let item = items[selectedIndex]
        item.isSelected = true
        //onItemTapped((item))
    }
    
    public func cancelTapped() {
        onCancelTapped(())
    }
}
