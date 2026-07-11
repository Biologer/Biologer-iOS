//
//  RegistrationPersonalInfoViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import SwiftUI

public final class RegistrationPersonalInfoViewModel: ObservableObject {
    @Published
    var userNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = NameTextFieldViewModel()

    @Published
    var lastNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = SurnameTextFieldViewModel()

    @Published
    var institutionTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = InsititutionTextFieldViewModel()

    @Published
    private var user: RegistrationDraft

    private let useCase: RegisterUserUseCase
    private let onNextTapped: Observer<Void>

    init(
        user: RegistrationDraft,
        useCase: RegisterUserUseCase,
        onNextTapped: @escaping Observer<Void>
    ) {
        self.useCase = useCase
        self.onNextTapped = onNextTapped
        self.user = user
    }

    func nextButtonTapped() {
        validateFields()
    }

    private func validateFields() {
        do throws(RegisterUserValidationError) {
            try useCase.updatePersonalInfo(
                username: userNameTextFieldViewModel.text,
                lastName: lastNameTextFieldViewModel.text,
                institution: institutionTextFieldViewModel.text,
                for: user
            )
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
