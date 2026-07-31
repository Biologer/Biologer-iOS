//
//  RegistrationPersonalInfoViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import SwiftUI

@MainActor
public final class RegistrationPersonalInfoViewModel: ObservableObject {
    @Published
    var userNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = NameTextFieldViewModel()

    @Published
    var lastNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = SurnameTextFieldViewModel()

    @Published
    var institutionTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = InsititutionTextFieldViewModel()

    private let user: RegistrationDraft

    private let validator: RegistrationPersonalInfoValidating
    private let onNextTapped: Observer<Void>

    init(
        user: RegistrationDraft,
        validator: RegistrationPersonalInfoValidating,
        onNextTapped: @escaping Observer<Void>
    ) {
        self.validator = validator
        self.onNextTapped = onNextTapped
        self.user = user
    }

    func nextButtonTapped() {
        validateFields()
    }

    private func validateFields() {
        do throws(RegisterUserValidationError) {
            let personalInfo = try validator.validatePersonalInfo(
                firstName: userNameTextFieldViewModel.text,
                lastName: lastNameTextFieldViewModel.text,
                institution: institutionTextFieldViewModel.text
            )
            user.username = personalInfo.firstName
            user.lastname = personalInfo.lastName
            user.institution = personalInfo.institution
            setAllFieldsAreValid()
            onNextTapped(())
        } catch {
            handle(error)
        }
    }

    private func handle(_ error: RegisterUserValidationError) {
        switch error {
        case .emptyUsername:
            setNameIsRequired()
        case .emptyLastName:
            setLastNameIsRequired()
        default:
            break
        }
    }
}

extension RegistrationPersonalInfoViewModel {
    private func setNameIsRequired() {
        objectWillChange.send()
        userNameTextFieldViewModel.setInvalid(with: "Common.tf.error.required".localized)
    }

    private func setLastNameIsRequired() {
        objectWillChange.send()
        lastNameTextFieldViewModel.setInvalid(with: "Common.tf.error.required".localized)
    }

    private func setAllFieldsAreValid() {
        objectWillChange.send()
        userNameTextFieldViewModel.setValid()
        lastNameTextFieldViewModel.setValid()
    }
}
