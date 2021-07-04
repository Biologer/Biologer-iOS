//
//  RegisterStepTwoScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import Foundation

public final class RegisterStepTwoScreenViewModel: RegisterStepTwoScreenLoader {
    var emailTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = EmailTextFieldViewModel()
    var passwordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = RegisterPasswordTextFieldViewModel()
    var repeatPasswordTextFieldViewModel: MaterialDesignTextFieldViewMoodelProtocol = RepeatPasswordTextFieldViewModel()
    var buttonTitle = "Next"
    
    private let user: User
    private let onNextTapped: Observer<User>
    
    init(user: User, onNextTapped: @escaping Observer<User>) {
        self.onNextTapped = onNextTapped
        self.user = user
    }
    
    func nextButtonTapped() {
        onNextTapped((user))
    }
}
