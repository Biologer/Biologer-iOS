//
//  RegistrationLicenseConsentScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import SwiftUI

struct RegistrationLicenseConsentScreen: View {

    private let dataLicense: CheckMarkItem
    private let imageLicense: CheckMarkItem

    @StateObject
    private var viewModel: RegistrationLicenseConsentViewModel

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
            ScrollView {
                VStack(spacing: 20) {
                    Color.clear
                    Image(viewModel.topImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                    RegisterLicenseView(
                        dataLicense: viewModel.dataLicense,
                        onDataTapped: viewModel.dataLicenseTapped)
                    RegisterLicenseView(
                        dataLicense: viewModel.imageLicense,
                        onDataTapped: viewModel.imageLicenseTapped)
                    Text("Register.three.lb.description".localized)
                        .font(.titleFont)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Button(action: {
                        viewModel.onReadPrivacyPolicy(())
                    }, label: {
                        AttributedTextView(
                            configuration: { label in
                                label.attributedText = createUnderlinePrivacyPolicy(text: "Register.three.btn.privacyPolicy".localized)
                                label.numberOfLines = 0
                                label.textAlignment = .center
                                label.textColor = UIColor.biologerGreenColor
                            })
                    })

                    HStack {
                        CheckView(
                            isChecked: false,
                            onToggle: { isChecked in
                                viewModel.acceptPPCheckMark = isChecked
                            })
                        Text("Register.three.lb.acceptPrivacyPolicy".localized)
                            .font(.titleFont)
                        Spacer()
                    }
                    BiologerButton(
                        title: "Register.three.btn.register".localized,
                        onTapped: { _ in
                            Task {
                                await viewModel.registerTapped()
                            }
                        })
                    ErrorLabelView(text: viewModel.errorLabel)
                        .font(.titleFont)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                }
                .padding(.horizontal, 30)
            }
            if viewModel.isLoading {
                BiologerProgressView()
            }
        }
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
                PopUpConfirmScreen(
                    popUpType: .error,
                    title: error.summary.isEmpty ? "API.lb.error".localized : error.summary,
                    description: error.message,
                    onButtonTapped: {
                        viewModel.dismissRegistrationPopup()
                    }
                )
            case .success:
                PopUpConfirmScreen(
                    popUpType: .success,
                    title: "Register.three.successPopUp.title".localized,
                    description: "Register.three.successPopUp.description".localized,
                    onButtonTapped: {
                        viewModel.confirmRegistrationSuccess()
                    }
                )
            }
        }
    }

    public func createUnderlinePrivacyPolicy(text: String) -> NSMutableAttributedString {
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        return NSMutableAttributedString(string: text, attributes: underlineAttribute)
    }
}

struct RegistrationLicenseConsentScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationLicenseConsentScreen(
            viewModel: RegistrationLicenseConsentViewModel(
                user: RegistrationDraft(),
                topImage: "",
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

        func createUser(request: RegistrationRequest) async throws(AuthorizationFailure) -> Void {}
    }
}
