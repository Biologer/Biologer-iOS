//
//  RepeatPasswordTextFieldViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public final class RepeatPasswordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol {
    public var text: String = ""
    public var placeholder: String = "Repeat Password"
    public var errorText: String = ""
    public var isCodeEntry: Bool = true
    public var tralingImage: String? = "user_icon"
    public var tralingErrorImage: String? = nil
    public var isUserInteractionEnabled: Bool = true
    public var type: MaterialDesignTextFieldType = .success
}
