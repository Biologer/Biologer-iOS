//
//  PasswordTextFieldViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 17.4.21..
//

import Foundation

public final class PasswordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol {
    public var text: String = ""
    public var placeholder: String = "Password"
    public var errorText: String = ""
    public var isCodeEntry: Bool = true
    public var tralingImage: String? = "user_icon"
    public var tralingErrorImage: String? = nil
    public var isUserInteractionEnabled: Bool = true
    public var type: MaterialDesignTextFieldType = .success
}
