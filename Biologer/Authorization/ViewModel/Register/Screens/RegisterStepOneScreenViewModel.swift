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
        onNextTapped((user))
    }
}
