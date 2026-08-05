import SwiftUI

struct LoginScreen: View {
    private let environmentViewModel: EnvironmentViewModel

    @StateObject private var viewModel: LoginScreenViewModel

    init(
        environmentViewModel: EnvironmentViewModel,
        viewModel: LoginScreenViewModel
    ) {
        self.environmentViewModel = environmentViewModel
        _viewModel = StateObject(wrappedValue: viewModel)
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
                            await viewModel.login()
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

                            Button(action: viewModel.register) {
                                Text("Login.btn.register".localized)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(BiologerColors.sectionTitle)
                            }
                            .buttonStyle(.plain)
                        }

                        Button(action: viewModel.forgotPassword) {
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
                AuthorizationLoadingOverlay()
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
        Button(action: viewModel.selectEnvironment) {
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

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen(
            environmentViewModel: EnvironmentViewModelFactory()
                .createEnvironment(type: .croatia),
            viewModel: LoginScreenViewModel(
                environmentViewModel: EnvironmentViewModelFactory()
                    .createEnvironment(type: .croatia),
                useCase: StubLoginUseCase(),
                onSelectEnvironmentTapped: {},
                onLoginSuccess: {},
                onRegisterTapped: {},
                onForgotPasswordTapped: {},
                onLoginError: { _ in }
            )
        )
    }

    private final class StubLoginUseCase: LoginUserUseCase {
        func login(
            email: String,
            username: String,
            password: String
        ) async throws(LoginError) {
        }
    }
}
