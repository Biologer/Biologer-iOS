//
//  InsititutionTextFieldViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public final class InsititutionTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol {
    public var text: String = ""
    public var placeholder: String = "Surname"
    public var errorText: String = ""
    public var isCodeEntry: Bool = false
    public var tralingImage: String? = nil
    public var tralingErrorImage: String? = nil
    public var isUserInteractionEnabled: Bool = true
    public var type: MaterialDesignTextFieldType = .success
}
