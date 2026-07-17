//
//  RegistrationCredentialsScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import SwiftUI

struct RegistrationCredentialsScreen: View {

    @StateObject
    private var viewModel: RegistrationCredentialsViewModel

    init(viewModel: RegistrationCredentialsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

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
            registrationUseCase: StubRegistrationUseCase(),
            onNextTapped: { _ in }
        ))
    }

    private class StubRegistrationUseCase: RegistrationUseCase {
        func validatePersonalInfo(
            firstName: String,
            lastName: String,
            institution: String
        ) throws(RegisterUserValidationError) -> RegistrationPersonalInfo {
            RegistrationPersonalInfo(firstName: firstName, lastName: lastName, institution: institution)
        }

        func validateCredentials(
            email: String,
            password: String,
            repeatedPassword: String
        ) throws(RegisterUserValidationError) -> RegistrationCredentials {
            RegistrationCredentials(email: email, password: password)
        }

        func saveData(license: CheckMarkItem) {}
        func saveImage(license: CheckMarkItem) {}
        func createUser(request: RegistrationRequest) async throws(APIError) -> Void {}
    }
}
