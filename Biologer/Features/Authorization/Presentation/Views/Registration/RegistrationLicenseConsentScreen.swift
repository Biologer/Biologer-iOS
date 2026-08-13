import SwiftUI

struct RegistrationLicenseConsentScreen: View {
    private let onPrivacyPolicy: () -> Void
    private let onDataLicense: (CheckMarkItem) -> Void
    private let onImageLicense: (CheckMarkItem) -> Void
    private let onRegistrationSuccess: () async -> Void

    @ObservedObject private var viewModel: RegistrationLicenseConsentViewModel

    init(
        viewModel: RegistrationLicenseConsentViewModel,
        onPrivacyPolicy: @escaping () -> Void,
        onDataLicense: @escaping (CheckMarkItem) -> Void,
        onImageLicense: @escaping (CheckMarkItem) -> Void,
        onRegistrationSuccess: @escaping () async -> Void
    ) {
        self.onPrivacyPolicy = onPrivacyPolicy
        self.onDataLicense = onDataLicense
        self.onImageLicense = onImageLicense
        self.onRegistrationSuccess = onRegistrationSuccess
        self.viewModel = viewModel
    }

    var body: some View {
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
                            action: { onDataLicense(viewModel.dataLicense) }
                        )

                        AuthorizationNavigationCard(
                            title: viewModel.imageLicense.title,
                            subtitle: viewModel.imageLicense.placeholder,
                            systemImage: "photo",
                            action: { onImageLicense(viewModel.imageLicense) }
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

                    Button(action: onPrivacyPolicy) {
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
        .biologerPageBackground()
        .biologerLoadingOverlay(isPresented: viewModel.isLoading)
        .navigationBarBackButtonHidden(true)
        .sheet(item: $viewModel.registrationPopup) { popup in
            switch popup {
            case .error(let error):
                BiologerResultSheet(
                    style: .failure,
                    title: error.summary.isEmpty
                        ? "API.lb.error".localized
                        : error.summary,
                    message: error.message,
                    onConfirm: viewModel.dismissRegistrationPopup
                )
            case .success:
                BiologerResultSheet(
                    style: .success,
                    title: "Register.three.successPopUp.title".localized,
                    message: "Register.three.successPopUp.description".localized,
                    onConfirm: {
                        Task {
                            viewModel.confirmRegistrationSuccess()
                            await onRegistrationSuccess()
                        }
                    }
                )
            }
        }
    }
}
