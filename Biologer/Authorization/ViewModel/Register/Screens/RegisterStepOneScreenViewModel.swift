//
//  RegisterStepOneScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public final class RegisterStepOneScreenViewModel: RegisterStepOneScreenLoader, ObservableObject {
    @Published var userNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = NameTextFieldViewModel()
    @Published var lastNameTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = SurnameTextFieldViewModel()
    @Published var institutionTextFieldViewModel: MaterialDesignTextFieldViewModelProtocol = InsititutionTextFieldViewModel()
    var buttonTitle = "Register.one.btn.next".localized
    
    private let user: User
    private let onNextTapped: Observer<User>
    
    init(user: User, onNextTapped: @escaping Observer<User>) {
        self.onNextTapped = onNextTapped
        self.user = user
    }
    
    func nextButtonTapped() {
        validateFields()
    }
    
    private func validateFields() {
        if userNameTextFieldViewModel.text.isEmpty {
            setNameIsRequired()
            return
        }
        
        user.username = userNameTextFieldViewModel.text
        
        if lastNameTextFieldViewModel.text.isEmpty {
            setLastNameIsRequired()
            return
        }
        
        user.lastname = lastNameTextFieldViewModel.text
        setAllFieldsAreValid()
        onNextTapped((user))
    }
}

extension RegisterStepOneScreenViewModel {
    private func setNameIsRequired() {
        userNameTextFieldViewModel.errorText = "Common.tf.error.required".localized
        userNameTextFieldViewModel.type = .failure
    }
    
    private func setLastNameIsRequired() {
        lastNameTextFieldViewModel.errorText = "Common.tf.error.required".localized
        lastNameTextFieldViewModel.type = .failure
    }
    
    private func setAllFieldsAreValid() {
        userNameTextFieldViewModel.errorText = ""
        userNameTextFieldViewModel.type = .success
        lastNameTextFieldViewModel.errorText = ""
        lastNameTextFieldViewModel.type = .success
    }
}
