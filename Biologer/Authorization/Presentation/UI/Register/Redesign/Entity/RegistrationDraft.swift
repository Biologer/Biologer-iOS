//
//  RegistrationDraft.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import Combine

public final class RegistrationDraft: ObservableObject {
    public var username: String = ""
    public var lastname: String = ""
    public var institution: String = ""
    public var email: String = ""
    public var password: String = ""
    public var dataLicense: CheckMarkItem = CheckMarkItem(id: 1, title: "", placeholder: "", type: .data, isSelected: false)
    public var imageLicense: CheckMarkItem = CheckMarkItem(id: 1, title: "", placeholder: "", type: .image, isSelected: false)
}
