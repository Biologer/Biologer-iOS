//
//  RegistrationPersonalInfoScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import SwiftUI

struct RegistrationPersonalInfoScreen: View {

    @StateObject
    private var loader: RegistrationPersonalInfoViewModel

    init(loader: RegistrationPersonalInfoViewModel) {
        _loader = StateObject(wrappedValue: loader)
    }

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
