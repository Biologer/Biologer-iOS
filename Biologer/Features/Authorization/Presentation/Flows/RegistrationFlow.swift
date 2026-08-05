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
    private let environmentImage: String
    private let onPrivacyPolicy: Observer<Void>
    private let registrationSuccess: Observer<Void>

    init(
        path: Binding<NavigationPath>,
        registrationUseCase: RegistrationUseCase,
        environmentImage: String,
        onPrivacyPolicy: @escaping Observer<Void>,
        registrationSuccess: @escaping Observer<Void>
    ) {
        self.registrationUseCase = registrationUseCase
        self.environmentImage = environmentImage
        self.onPrivacyPolicy = onPrivacyPolicy
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
                        onSelectionChanged: { _ in
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
                        onSelectionChanged: { _ in
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
                validator: registrationUseCase,
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
                validator: registrationUseCase,
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
                registerUserUseCase: registrationUseCase,
                dataLicense: selectedDataLicense,
                imageLicense: selectedImageLicense,
                onReadPrivacyPolicy: {
                    onPrivacyPolicy(())
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

    private func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
