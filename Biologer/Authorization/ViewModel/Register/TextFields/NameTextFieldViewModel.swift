//
//  NameTextFieldViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public final class NameTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol {
    public var text: String = ""
    public var placeholder: String = "Name"
    public var errorText: String = ""
    public var isCodeEntry: Bool = false
    public var tralingImage: String? = "user_icon"
    public var tralingErrorImage: String? = nil
    public var isUserInteractionEnabled: Bool = true
    public var type: MaterialDesignTextFieldType = .success
}