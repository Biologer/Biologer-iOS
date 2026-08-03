import SwiftUI

struct RegistrationCredentialsScreen: View {
    @StateObject private var viewModel: RegistrationCredentialsViewModel

    init(viewModel: RegistrationCredentialsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: BiologerSpacing.large) {
                AuthorizationStepHeader(
                    step: 2,
                    totalSteps: 3,
                    systemImage: "lock.shield"
                )
                .padding(.top, BiologerSpacing.small)

                VStack(spacing: BiologerSpacing.small) {
                    AuthorizationTextField(
                        text: Binding(
                            get: { viewModel.email },
                            set: viewModel.updateEmail
                        ),
                        placeholder: "Register.two.tf.email.placeholder".localized,
                        errorText: viewModel.emailError,
                        systemImage: "envelope",
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress
                    )

                    AuthorizationTextField(
                        text: Binding(
                            get: { viewModel.password },
                            set: viewModel.updatePassword
                        ),
                        placeholder: "Register.two.tf.password.placeholder".localized,
                        errorText: viewModel.passwordError,
                        systemImage: "lock",
                        textContentType: .password,
                        isSecure: true
                    )

                    AuthorizationTextField(
                        text: Binding(
                            get: { viewModel.repeatedPassword },
                            set: viewModel.updateRepeatedPassword
                        ),
                        placeholder: "Register.two.tf.repeatPassword.placeholder".localized,
                        errorText: viewModel.repeatedPasswordError,
                        systemImage: "lock.rotation",
                        textContentType: .password,
                        isSecure: true
                    )
                }

                Button(action: viewModel.nextButtonTapped) {
                    Label(
                        "Register.two.btn.next".localized,
                        systemImage: "arrow.right"
                    )
                }
                .buttonStyle(BiologerActionButtonStyle())
            }
            .padding(.horizontal, BiologerSpacing.regular)
            .padding(.bottom, BiologerSpacing.xxLarge)
        }
        .biologerPageBackground()
        .navigationBarBackButtonHidden(true)
    }
}

struct RegistrationCredentialsScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationCredentialsScreen(
            viewModel: RegistrationCredentialsViewModel(
                user: RegistrationDraft(),
                validator: StubRegistrationUseCase(),
                onNextTapped: { _ in }
            )
        )
    }

    private final class StubRegistrationUseCase: RegistrationUseCase {
        func validatePersonalInfo(
            firstName: String,
            lastName: String,
            institution: String
        ) throws(RegisterUserValidationError) -> RegistrationPersonalInfo {
            RegistrationPersonalInfo(
                firstName: firstName,
                lastName: lastName,
                institution: institution
            )
        }

        func validateCredentials(
            email: String,
            password: String,
            repeatedPassword: String
        ) throws(RegisterUserValidationError) -> RegistrationCredentials {
            RegistrationCredentials(email: email, password: password)
        }

        func createUser(
            request: RegistrationRequest
        ) async throws(AuthorizationFailure) {
        }
    }
}
