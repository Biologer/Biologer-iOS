import SwiftUI

struct RegistrationCredentialsScreen: View {
    @ObservedObject private var viewModel: RegistrationFlowViewModel
    private let onNext: () -> Void

    init(
        viewModel: RegistrationFlowViewModel,
        onNext: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onNext = onNext
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
                            get: { viewModel.draft.email },
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
                            get: { viewModel.draft.password },
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
                            get: { viewModel.draft.repeatedPassword },
                            set: viewModel.updateRepeatedPassword
                        ),
                        placeholder: "Register.two.tf.repeatPassword.placeholder".localized,
                        errorText: viewModel.repeatedPasswordError,
                        systemImage: "lock.rotation",
                        textContentType: .password,
                        isSecure: true
                    )
                }

                Button {
                    guard viewModel.validateCredentials() else { return }
                    onNext()
                } label: {
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
