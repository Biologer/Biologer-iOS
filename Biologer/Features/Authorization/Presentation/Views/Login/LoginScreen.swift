import SwiftUI

struct LoginScreen: View {
    private let environmentViewModel: EnvironmentViewModel
    private let onSelectEnvironment: () -> Void
    private let onLoginSuccess: () -> Void
    private let onLoginError: Observer<AuthorizationFailure>
    private let onRegister: () -> Void
    private let onForgotPassword: () -> Void

    @ObservedObject private var viewModel: LoginScreenViewModel

    init(
        environmentViewModel: EnvironmentViewModel,
        viewModel: LoginScreenViewModel,
        onSelectEnvironment: @escaping () -> Void,
        onLoginSuccess: @escaping () -> Void,
        onLoginError: @escaping Observer<AuthorizationFailure>,
        onRegister: @escaping () -> Void,
        onForgotPassword: @escaping () -> Void
    ) {
        self.environmentViewModel = environmentViewModel
        self.onSelectEnvironment = onSelectEnvironment
        self.onLoginSuccess = onLoginSuccess
        self.onLoginError = onLoginError
        self.onRegister = onRegister
        self.onForgotPassword = onForgotPassword
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: BiologerSpacing.large) {
                    AuthorizationBrandHeader(
                        environmentImage: viewModel.environmentViewModel.image
                    )

                    VStack(spacing: BiologerSpacing.small) {
                        AuthorizationTextField(
                            text: Binding(
                                get: { viewModel.email },
                                set: viewModel.updateEmail
                            ),
                            placeholder: "Login.tf.username.placeholder".localized,
                            errorText: viewModel.emailError,
                            systemImage: "envelope",
                            keyboardType: .emailAddress,
                            textContentType: .username
                        )

                        AuthorizationTextField(
                            text: Binding(
                                get: { viewModel.password },
                                set: viewModel.updatePassword
                            ),
                            placeholder: "Login.tf.password.placeholder".localized,
                            errorText: viewModel.passwordError,
                            systemImage: "lock",
                            textContentType: .password,
                            isSecure: true
                        )
                    }

                    environmentCard

                    Button {
                        Task {
                            switch await viewModel.login() {
                            case .success:
                                onLoginSuccess()
                            case .authorizationFailure(let error):
                                onLoginError(error)
                            case .validationFailure:
                                break
                            }
                        }
                    } label: {
                        Label(
                            "Login.btn.login".localized,
                            systemImage: "arrow.right.circle.fill"
                        )
                    }
                    .buttonStyle(BiologerActionButtonStyle())

                    VStack(spacing: BiologerSpacing.regular) {
                        HStack(spacing: BiologerSpacing.xSmall) {
                            Text("Login.lb.noAccount".localized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Button(action: onRegister) {
                                Text("Login.btn.register".localized)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(BiologerColors.sectionTitle)
                            }
                            .buttonStyle(.plain)
                        }

                        Button(action: onForgotPassword) {
                            Text("Login.btn.forgotPassword".localized)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(BiologerColors.sectionTitle)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, BiologerSpacing.xxSmall)
                }
                .padding(.horizontal, BiologerSpacing.regular)
                .padding(.top, BiologerSpacing.small)
                .padding(.bottom, BiologerSpacing.xxLarge)
            }

            if viewModel.isLoading {
                BiologerLoadingOverlay()
            }
        }
        .biologerPageBackground()
        .onAppear {
            viewModel.updateEnvironment(environmentViewModel)
        }
        .onChange(of: environmentViewModel) { environment in
            viewModel.updateEnvironment(environment)
        }
    }

    private var environmentCard: some View {
        Button(action: onSelectEnvironment) {
            HStack(spacing: BiologerSpacing.small) {
                Image(viewModel.environmentViewModel.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
                    Text("Login.env.placeholder".localized.uppercased())
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(BiologerColors.sectionTitle)
                        .tracking(0.4)

                    Text(viewModel.environmentViewModel.title)
                        .font(.body.weight(.medium))
                        .foregroundColor(BiologerColors.textPrimary)
                }

                Spacer(minLength: BiologerSpacing.xSmall)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(Color(uiColor: .tertiaryLabel))
            }
            .padding(BiologerSpacing.regular)
            .contentShape(Rectangle())
            .biologerCard()
        }
        .buttonStyle(.plain)
    }
}
