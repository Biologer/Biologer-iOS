//
//  RegistrationLicenseConsentScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import SwiftUI

struct RegistrationLicenseConsentScreen: View {

    @ObservedObject
    var viewModel: RegistrationLicenseConsentViewModel

    var body: some View {
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
        .navigationBarBackButtonHidden(true)
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
                useCase: StubUseCase(),
                dataLicense: CheckMarkItemMapper.getDataLicense()[0],
                imageLicense: CheckMarkItemMapper.getImageLicense()[0],
                onReadPrivacyPolicy: { _ in },
                onDataLicense: { _ in },
                onImageLicense: { _ in },
                onSuccess: { _ in },
                onError: { _ in }
            )
        )
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
        func createUser(user: RegistrationDraft) async throws(APIError) { }
    }

    private class StubLicenceStorage: LicenseStorage {
        func getLicense() -> CheckMarkItem? { return nil }
        func saveLicense(license: CheckMarkItem) {}
        func delete() {}
    }
}
