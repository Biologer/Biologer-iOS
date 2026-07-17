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

    @StateObject
    private var registrationUser: RegistrationDraft

    @Binding
    private var path: NavigationPath

    @State
    private var selectedImageLicense: CheckMarkItem = CheckMarkItemMapper.getImageLicense()[0]

    @State
    private var selectedDataLicense: CheckMarkItem = CheckMarkItemMapper.getDataLicense()[0]

    private let registrationUseCase: RegistrationUseCase
    private let environment: Environment
    private let environmentImage: String
    private let registrationSuccess: Observer<Void>

    init(
        path: Binding<NavigationPath>,
        registrationUseCase: RegistrationUseCase,
        environment: Environment,
        environmentImage: String,
        registrationSuccess: @escaping Observer<Void>
    ) {
        self.registrationUseCase = registrationUseCase
        self.environment = environment
        self.environmentImage = environmentImage
        self.registrationSuccess = registrationSuccess
        _path = path
        _registrationUser = .init(wrappedValue: RegistrationDraft())
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
                        selectedItem: $selectedImageLicense,
                        items: CheckMarkItemMapper.getImageLicense(),
                        onSelectionChanged: { license in
                            registrationUseCase.saveImage(license: license)
                            goBack()
                        }
                    )
                    .authorizationNavigationBar(
                        title: "ImgLicense.nav.title".localized,
                        onBack: {
                            goBack()
                        }
                    )
                case .dataLicense:
                    LicenseSelectionScreen(
                        selectedItem: $selectedDataLicense,
                        items: CheckMarkItemMapper.getDataLicense(),
                        onSelectionChanged: { license in
                            registrationUseCase.saveData(license: license)
                            goBack()
                        }
                    )
                    .authorizationNavigationBar(
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
            loader: RegistrationPersonalInfoViewModel(
                user: registrationUser,
                registrationUseCase: registrationUseCase,
                onNextTapped: {
                    path.append(Screen.secondStep)
                })
        )
        .authorizationNavigationBar(
            title: "Register.one.nav.title".localized,
            onBack: {
                goBack()
            }
        )
    }

    private var secondStepScreen: some View {
        RegistrationCredentialsScreen(
            viewModel: RegistrationCredentialsViewModel(
                user: registrationUser,
                registrationUseCase: registrationUseCase,
                onNextTapped: {
                    path.append(Screen.thirdStep)
                })
        )
        .authorizationNavigationBar(
            title: "Register.two.nav.title".localized,
            onBack: {
                goBack()
            }
        )
    }

    private var thirdStepScreen: some View {
        RegistrationLicenseConsentScreen(
            viewModel: RegistrationLicenseConsentViewModel(
                user: registrationUser,
                topImage: environmentImage,
                registrationUseCase: registrationUseCase,
                dataLicense: selectedDataLicense,
                imageLicense: selectedImageLicense,
                onReadPrivacyPolicy: {
                    showSafari(path: "/pages/privacy-policy")
                },
                onDataLicense: { dataLicense in
                    path.append(Screen.dataLicense)
                },
                onImageLicense: { imageLicense in
                    path.append(Screen.imageLicense)
                },
                onSuccess: { _ in
                    registrationSuccess(())
                }
            ),
            dataLicense: selectedDataLicense,
            imageLicense: selectedImageLicense
        )
        .authorizationNavigationBar(
            title: "Register.three.nav.title".localized,
            onBack: {
                goBack()
            }
        )
    }

    private func showSafari(path: String) {
        let url = "https://\(environment.host)\(environment.path)\(path)"
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }

    private func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
