//
//  SurnameTextFieldViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import UIKit

public final class SurnameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol {
    public var textAligment: NSTextAlignment = .left
    public var onChange: Observer<MaterialDesignTextFieldViewModelProtocol>?
    public var text: String = ""
    public var placeholder: String = "Surname"
    public var errorText: String = ""
    public var isCodeEntry: Bool = false
    public var tralingImage: String? = "user_icon"
    public var tralingErrorImage: String? = nil
    public var isUserInteractionEnabled: Bool = true
    public var type: MaterialDesignTextFieldType = .success
}
