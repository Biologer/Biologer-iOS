//
//  RegistrationDraft.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import Combine

public final class RegistrationDraft: ObservableObject {
    @Published public var username: String = ""
    @Published public var lastname: String = ""
    @Published public var institution: String = ""
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var dataLicense: CheckMarkItem = CheckMarkItem(id: 1, title: "", placeholder: "", type: .data, isSelected: false)
    @Published public var imageLicense: CheckMarkItem = CheckMarkItem(id: 1, title: "", placeholder: "", type: .image, isSelected: false)
}
