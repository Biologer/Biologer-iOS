//
//  RegistrationFlow.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import SwiftUI

struct RegistrationFlow: View {

    enum Screen: String {
        case secondStep
        case thirdStep
        case imageLicense
        case dataLicense
    }

    @ObservedObject
    private var viewModel: RegistrationFlowViewModel

    @Binding
    private var path: NavigationPath

    private let onPrivacyPolicy: () -> Void
    private let registrationSuccess: () -> Void

    init(
        path: Binding<NavigationPath>,
        viewModel: RegistrationFlowViewModel,
        onPrivacyPolicy: @escaping () -> Void,
        registrationSuccess: @escaping () -> Void
    ) {
        self.onPrivacyPolicy = onPrivacyPolicy
        self.registrationSuccess = registrationSuccess
        _path = path
        self.viewModel = viewModel
    }

    var body: some View {
        firstStepScreen
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .secondStep:
                    secondStepScreen
                case .thirdStep:
                    thirdStepScreen
                case .imageLicense:
                    LicenseSelectionScreen(
                        selectedItem: $viewModel.selectedImageLicense,
                        items: viewModel.imageLicenses,
                        onSelectionChanged: { _ in
                            goBack()
                        }
                    )
                    .biologerNavigationBar(
                        title: "ImgLicense.nav.title".localized,
                        onBack: {
                            goBack()
                        }
                    )
                case .dataLicense:
                    LicenseSelectionScreen(
                        selectedItem: $viewModel.selectedDataLicense,
                        items: viewModel.dataLicenses,
                        onSelectionChanged: { _ in
                            goBack()
                        }
                    )
                    .biologerNavigationBar(
                        title: "DataLicense.nav.title".localized,
                        onBack: {
                            goBack()
                        }
                    )
                }
            }
    }

    // MARK: - Register Steps Screens
    private var firstStepScreen: some View {
        RegistrationPersonalInfoScreen(
            loader: viewModel.personalInfoViewModel,
            onNext: {
                path.append(Screen.secondStep)
            }
        )
        .biologerNavigationBar(
            title: "Register.one.nav.title".localized,
            onBack: {
                goBack()
            }
        )
    }

    private var secondStepScreen: some View {
        RegistrationCredentialsScreen(
            viewModel: viewModel.credentialsViewModel,
            onNext: {
                path.append(Screen.thirdStep)
            }
        )
        .biologerNavigationBar(
            title: "Register.two.nav.title".localized,
            onBack: {
                goBack()
            }
        )
    }

    private var thirdStepScreen: some View {
        RegistrationLicenseConsentScreen(
            viewModel: viewModel.licenseConsentViewModel,
            dataLicense: viewModel.selectedDataLicense,
            imageLicense: viewModel.selectedImageLicense,
            onPrivacyPolicy: onPrivacyPolicy,
            onDataLicense: { _ in path.append(Screen.dataLicense) },
            onImageLicense: { _ in path.append(Screen.imageLicense) },
            onRegistrationSuccess: registrationSuccess
        )
        .biologerNavigationBar(
            title: "Register.three.nav.title".localized,
            onBack: {
                goBack()
            }
        )
    }

    private func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
