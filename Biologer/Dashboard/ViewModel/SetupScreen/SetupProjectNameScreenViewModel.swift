//
//  SetupProjectNameScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 18.9.21..
//

import UIKit

public final class SetupProjectNameScreenViewModel: ObservableObject {
    @Published var textField: MaterialDesignTextFieldViewModelProtocol
    public let okButtonTitle = "Common.btn.ok".localized
    public let cancelTitle = "Common.btn.cancel".localized
    
    private let useCase: SetupUseCase
    private let onCancelTapped: Observer<Void>
    private let onOkTapped: Observer<String>
    
    init(useCase: SetupUseCase,
         onCancelTapped: @escaping Observer<Void>,
         onOkTapped: @escaping Observer<String>) {
        self.useCase = useCase
        self.onCancelTapped = onCancelTapped
        self.onOkTapped = onOkTapped
        self.textField = ProjectNameTextFieldViewModel(text: useCase.projectName())
    }

    convenience init(
        settingsStorage: SettingsStorage,
        onCancelTapped: @escaping Observer<Void>,
        onOkTapped: @escaping Observer<String>
    ) {
        self.init(
            useCase: SettingsStorageSetupUseCase(settingsStorage: settingsStorage),
            onCancelTapped: onCancelTapped,
            onOkTapped: onOkTapped
        )
    }
    
    public func cancelTapped() {
        onCancelTapped(())
    }
    
    public func okTapped() {
        useCase.saveProjectName(textField.text)
        onOkTapped((textField.text))
    }
    
    public final class ProjectNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol {
        public var textAligment: NSTextAlignment = .left
        public var onChange: Observer<MaterialDesignTextFieldViewModelProtocol>?
        public var text: String
        public var placeholder: String = "ProjectName.tf.placeholder".localized
        public var errorText: String = ""
        public var isCodeEntry: Bool = false
        public var tralingImage: String? = nil
        public var tralingErrorImage: String? = nil
        public var isUserInteractionEnabled: Bool = true
        public var type: MaterialDesignTextFieldType = .success
        
        init(text: String) {
            self.text = text
        }
    }
}
