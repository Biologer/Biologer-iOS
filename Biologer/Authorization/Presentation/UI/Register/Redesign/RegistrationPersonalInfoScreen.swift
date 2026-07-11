//
//  RegistrationPersonalInfoScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import SwiftUI

struct RegistrationPersonalInfoScreen: View {

    @ObservedObject
    var loader: RegistrationPersonalInfoViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear
                    .padding(.top, 10)
                MaterialDesignTextField(viewModel: loader.userNameTextFieldViewModel,
                                        onTextChanged: { text in

                                        },
                                        textAligment: .left)
                MaterialDesignTextField(viewModel: loader.lastNameTextFieldViewModel,
                                        onTextChanged: { text in

                                        },
                                        textAligment: .left)
                MaterialDesignTextField(viewModel: loader.institutionTextFieldViewModel,
                                        onTextChanged: { text in

                                        },
                                        textAligment: .left)
                BiologerButton(title: "Register.one.btn.next".localized,
                            onTapped: { _ in
                                loader.nextButtonTapped()
                            })
                    .padding(.top, 20)
            }
            .padding(.horizontal, 30)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct RegistrationPersonalInfoScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationPersonalInfoScreen(loader: RegistrationPersonalInfoViewModel(
            user: RegistrationDraft(),
            useCase: StubUseCase(),
            onNextTapped: { _ in }
        ))
    }

    private class StubUseCase: RegisterUserUseCase {
        let environment: Environment? = nil
        func saveData(license: CheckMarkItem) {}
        func saveImage(license: CheckMarkItem) {}
        func updatePersonalInfo(
            username: String,
            lastName: String,
            institution: String,
            for user: RegistrationDraft
        ) throws(RegisterUserValidationError) {}
        func updateCredentials(
            email: String,
            password: String,
            repeatedPassword: String,
            for user: RegistrationDraft
        ) throws(RegisterUserValidationError) {}
        func createUser(user: RegistrationDraft) async throws(APIError) {}
    }
}
