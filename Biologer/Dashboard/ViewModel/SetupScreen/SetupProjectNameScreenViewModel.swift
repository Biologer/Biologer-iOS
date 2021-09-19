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
    
    private let onCancelTapped: Observer<Void>
    private let onOkTapped: Observer<String>
    
    init(projectName: String,
         onCancelTapped: @escaping Observer<Void>,
         onOkTapped: @escaping Observer<String>) {
        self.textField = ProjectNameTextFieldViewModel(text: projectName)
        self.onCancelTapped = onCancelTapped
        self.onOkTapped = onOkTapped
    }
    
    public func cancelTapped() {
        onCancelTapped(())
    }
    
    public func okTapped() {
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
