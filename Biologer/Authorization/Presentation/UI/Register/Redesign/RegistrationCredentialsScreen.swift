//
//  RegistrationCredentialsScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import SwiftUI

struct RegistrationCredentialsScreen: View {

    @ObservedObject
    var viewModel: RegistrationCredentialsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear
                    .padding(.top, 10)
                MaterialDesignTextField(
                    viewModel: viewModel.emailTextFieldViewModel,
                    onTextChanged: { text in
                    },
                    textAligment: .left)

                MaterialDesignTextField(
                    viewModel: viewModel.passwordTextFieldViewModel,
                    onTextChanged: { text in

                    },
                    onIconTapped: { _ in
                        viewModel.toggleIsCodeEntryPassword()
                    },
                    textAligment: .left)

                MaterialDesignTextField(
                    viewModel: viewModel.repeatPasswordTextFieldViewModel,
                    onTextChanged: { text in

                    },
                    onIconTapped: { _ in
                        viewModel.toggleIsCodeEntryRepeatPassword()
                    },
                    textAligment: .left)

                BiologerButton(
                    title: "Register.two.btn.next".localized,
                    onTapped: { _ in
                        viewModel.nextButtonTapped()
                    })
                .padding(.top, 20)
            }
            .padding(.horizontal, 30)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct RegistrationCredentialsScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationCredentialsScreen(viewModel: RegistrationCredentialsViewModel(
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
