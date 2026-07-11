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
    private var registrationError: APIError?

    @State
    private var selectedImageLicense: CheckMarkItem = CheckMarkItemMapper.getImageLicense()[0]

    @State
    private var selectedDataLicense: CheckMarkItem = CheckMarkItemMapper.getDataLicense()[0]

    private let useCase: RegisterUserUseCase
    private let environmentImage: String
    private let registrationSuccess: Observer<Void>

    init(
        path: Binding<NavigationPath>,
        useCase: RegisterUserUseCase,
        environmentImage: String,
        registrationSuccess: @escaping Observer<Void>
    ) {
        self.useCase = useCase
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
                        items: CheckMarkItemMapper.getImageLicense()
                    )
                    .onChange(of: selectedImageLicense) { license in
                        useCase.saveImage(license: license)
                        path.removeLast()
                    }
                case .dataLicense:
                    LicenseSelectionScreen(
                        selectedItem: $selectedDataLicense,
                        items: CheckMarkItemMapper.getDataLicense()
                    )
                    .onChange(of: selectedDataLicense) { license in
                        useCase.saveData(license: license)
                        path.removeLast()
                    }
                }
            }
    }

    // MARK: - Register Steps Screens
    private var firstStepScreen: some View {
        RegistrationPersonalInfoScreen(
            loader: RegistrationPersonalInfoViewModel(
                user: registrationUser,
                useCase: useCase,
                onNextTapped: {
                    path.append(Screen.secondStep)
                })
        )
    }

    private var secondStepScreen: some View {
        RegistrationCredentialsScreen(
            viewModel: RegistrationCredentialsViewModel(
                user: registrationUser,
                useCase: useCase,
                onNextTapped: {
                    path.append(Screen.thirdStep)
                })
        )
    }

    private var thirdStepScreen: some View {
        RegistrationLicenseConsentScreen(
            viewModel: RegistrationLicenseConsentViewModel(
                user: registrationUser,
                topImage: environmentImage,
                useCase: useCase,
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
                },
                onError: { error in
                    registrationError = error
                }
            )
        )
        .sheet(item: $registrationError) { error in
            PopUpConfirmScreen(
                popUpType: .error,
                title: error.title,
                description: error.description,
                onButtonTapped: {
                    registrationError = nil
                }
            )
        }
    }

    private func showSafari(path: String) {
        if let env = useCase.environment {
            let url = "https://\(env.host)\(env.path)\(path)"
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }
    }
}
