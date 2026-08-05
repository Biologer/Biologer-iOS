import SwiftUI

struct RegistrationLicenseConsentScreen: View {
    private let dataLicense: CheckMarkItem
    private let imageLicense: CheckMarkItem

    @StateObject private var viewModel: RegistrationLicenseConsentViewModel

    init(
        viewModel: RegistrationLicenseConsentViewModel,
        dataLicense: CheckMarkItem,
        imageLicense: CheckMarkItem
    ) {
        self.dataLicense = dataLicense
        self.imageLicense = imageLicense
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    VStack(spacing: BiologerSpacing.large) {
                        AuthorizationStepHeader(
                            step: 3,
                            totalSteps: 3,
                            systemImage: "checkmark.seal"
                        )
                        .padding(.top, BiologerSpacing.small)

                        if !viewModel.topImage.isEmpty {
                            Image(viewModel.topImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 48, height: 48)
                                .padding(BiologerSpacing.xSmall)
                                .background(.white, in: Circle())
                                .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
                        }

                        VStack(spacing: BiologerSpacing.small) {
                            AuthorizationNavigationCard(
                                title: viewModel.dataLicense.title,
                                subtitle: viewModel.dataLicense.placeholder,
                                systemImage: "doc.text",
                                action: viewModel.dataLicenseTapped
                            )

                            AuthorizationNavigationCard(
                                title: viewModel.imageLicense.title,
                                subtitle: viewModel.imageLicense.placeholder,
                                systemImage: "photo",
                                action: viewModel.imageLicenseTapped
                            )
                        }

                        Text("Register.three.lb.description".localized)
                            .font(.body)
                            .foregroundColor(BiologerColors.textPrimary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(BiologerSpacing.regular)
                            .biologerCard()

                        Button(action: viewModel.privacyPolicyTapped) {
                            Label(
                                "Register.three.btn.privacyPolicy".localized,
                                systemImage: "doc.text.magnifyingglass"
                            )
                        }
                        .buttonStyle(
                            BiologerActionButtonStyle(isFilled: false)
                        )

                        Toggle(
                            "Register.three.lb.acceptPrivacyPolicy".localized,
                            isOn: $viewModel.acceptPPCheckMark
                        )
                        .font(.body)
                        .foregroundColor(BiologerColors.textPrimary)
                        .tint(BiologerColors.accent)
                        .padding(BiologerSpacing.regular)
                        .biologerCard(
                            isSelected: viewModel.acceptPPCheckMark
                        )

                        if !viewModel.errorLabel.isEmpty {
                            Text(viewModel.errorLabel)
                                .font(.footnote.weight(.medium))
                                .foregroundColor(BiologerColors.destructive)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Button {
                            Task {
                                await viewModel.registerTapped()
                            }
                        } label: {
                            Label(
                                "Register.three.btn.register".localized,
                                systemImage: "person.badge.plus"
                            )
                        }
                        .buttonStyle(BiologerActionButtonStyle())
                    }
                    .frame(
                        width: max(
                            0,
                            geometry.size.width - (BiologerSpacing.regular * 2)
                        )
                    )
                    .padding(.horizontal, BiologerSpacing.regular)
                    .padding(.bottom, BiologerSpacing.xxLarge)
                }
            }

            if viewModel.isLoading {
                AuthorizationLoadingOverlay()
            }
        }
        .biologerPageBackground()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.updateDataLicense(dataLicense)
            viewModel.updateImageLicense(imageLicense)
        }
        .onChange(of: dataLicense) { license in
            viewModel.updateDataLicense(license)
        }
        .onChange(of: imageLicense) { license in
            viewModel.updateImageLicense(license)
        }
        .sheet(item: $viewModel.registrationPopup) { popup in
            switch popup {
            case .error(let error):
                AuthorizationResultSheet(
                    isSuccess: false,
                    title: error.summary.isEmpty
                        ? "API.lb.error".localized
                        : error.summary,
                    message: error.message,
                    onConfirm: viewModel.dismissRegistrationPopup
                )
            case .success:
                AuthorizationResultSheet(
                    isSuccess: true,
                    title: "Register.three.successPopUp.title".localized,
                    message: "Register.three.successPopUp.description".localized,
                    onConfirm: viewModel.confirmRegistrationSuccess
                )
            }
        }
    }
}

struct RegistrationLicenseConsentScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationLicenseConsentScreen(
            viewModel: RegistrationLicenseConsentViewModel(
                user: RegistrationDraft(),
                topImage: "serbia_flag",
                registerUserUseCase: StubRegistrationUseCase(),
                dataLicense: CheckMarkItemMapper.getDataLicense()[0],
                imageLicense: CheckMarkItemMapper.getImageLicense()[0],
                onReadPrivacyPolicy: { _ in },
                onDataLicense: { _ in },
                onImageLicense: { _ in },
                onSuccess: { _ in }
            ),
            dataLicense: CheckMarkItemMapper.getDataLicense()[0],
            imageLicense: CheckMarkItemMapper.getImageLicense()[0]
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
