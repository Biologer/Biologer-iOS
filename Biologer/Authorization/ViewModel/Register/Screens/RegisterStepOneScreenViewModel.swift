//
//  RegisterStepOneScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public final class RegisterStepOneScreenViewModel: RegisterStepOneScreenLoader, ObservableObject {
    @Published var userNameTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = NameTextFieldViewModel()
    @Published var lastNameTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = SurnameTextFieldViewModel()
    @Published var institutionTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = InsititutionTextFieldViewModel()
    var buttonTitle = "Next"
    
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
//        if userNameTextFieldViewModel.text.isEmpty {
//            setNameIsRequired()
//            return
//        }
//        
//        if lastNameTextFieldViewModel.text.isEmpty {
//            setLastNameIsRequired()
//            return
//        }
//        setAllFieldsAreValid()
        onNextTapped((user))
    }
}

extension RegisterStepOneScreenViewModel {
    private func setNameIsRequired() {
        userNameTextFieldViewModel.errorText = "Field is required"
        userNameTextFieldViewModel.type = .failure
    }
    
    private func setLastNameIsRequired() {
        lastNameTextFieldViewModel.errorText = "Field is required"
        lastNameTextFieldViewModel.type = .failure
    }
    
    private func setAllFieldsAreValid() {
        userNameTextFieldViewModel.errorText = ""
        userNameTextFieldViewModel.type = .success
        lastNameTextFieldViewModel.errorText = ""
        lastNameTextFieldViewModel.type = .success
    }
}
