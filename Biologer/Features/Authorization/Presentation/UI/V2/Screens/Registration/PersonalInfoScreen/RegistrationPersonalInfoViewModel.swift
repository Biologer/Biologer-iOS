//
//  RegistrationPersonalInfoViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import SwiftUI

@MainActor
public final class RegistrationPersonalInfoViewModel: ObservableObject {
    @Published private(set) var firstName: String
    @Published private(set) var lastName: String
    @Published private(set) var institution: String
    @Published private(set) var firstNameError: String?
    @Published private(set) var lastNameError: String?

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
        firstName = user.username
        lastName = user.lastname
        institution = user.institution
    }

    func nextButtonTapped() {
        validateFields()
    }

    func updateFirstName(_ firstName: String) {
        self.firstName = firstName
        firstNameError = nil
    }

    func updateLastName(_ lastName: String) {
        self.lastName = lastName
        lastNameError = nil
    }

    func updateInstitution(_ institution: String) {
        self.institution = institution
    }

    private func validateFields() {
        do throws(RegisterUserValidationError) {
            let personalInfo = try validator.validatePersonalInfo(
                firstName: firstName,
                lastName: lastName,
                institution: institution
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
        firstNameError = "Common.tf.error.required".localized
    }

    private func setLastNameIsRequired() {
        lastNameError = "Common.tf.error.required".localized
    }

    private func setAllFieldsAreValid() {
        firstNameError = nil
        lastNameError = nil
    }
}
