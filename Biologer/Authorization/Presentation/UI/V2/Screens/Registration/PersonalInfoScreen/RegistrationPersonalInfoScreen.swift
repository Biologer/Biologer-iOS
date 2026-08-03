import SwiftUI

struct RegistrationPersonalInfoScreen: View {
    @StateObject private var loader: RegistrationPersonalInfoViewModel

    init(loader: RegistrationPersonalInfoViewModel) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: BiologerSpacing.large) {
                AuthorizationStepHeader(
                    step: 1,
                    totalSteps: 3,
                    systemImage: "person.text.rectangle"
                )
                .padding(.top, BiologerSpacing.small)

                VStack(spacing: BiologerSpacing.small) {
                    AuthorizationTextField(
                        text: Binding(
                            get: { loader.firstName },
                            set: loader.updateFirstName
                        ),
                        placeholder: "Register.one.tf.name.placeholder".localized,
                        errorText: loader.firstNameError,
                        systemImage: "person",
                        textContentType: .givenName
                    )

                    AuthorizationTextField(
                        text: Binding(
                            get: { loader.lastName },
                            set: loader.updateLastName
                        ),
                        placeholder: "Register.one.tf.surname.placeholder".localized,
                        errorText: loader.lastNameError,
                        systemImage: "person",
                        textContentType: .familyName
                    )

                    AuthorizationTextField(
                        text: Binding(
                            get: { loader.institution },
                            set: loader.updateInstitution
                        ),
                        placeholder: "Register.one.tf.institution.placeholder".localized,
                        systemImage: "building.2",
                        textContentType: .organizationName
                    )
                }

                Button(action: loader.nextButtonTapped) {
                    Label(
                        "Register.one.btn.next".localized,
                        systemImage: "arrow.right"
                    )
                }
                .buttonStyle(BiologerActionButtonStyle())
            }
            .padding(.horizontal, BiologerSpacing.regular)
            .padding(.bottom, BiologerSpacing.xxLarge)
        }
        .biologerPageBackground()
        .navigationBarBackButtonHidden(true)
    }
}

struct RegistrationPersonalInfoScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationPersonalInfoScreen(
            loader: RegistrationPersonalInfoViewModel(
                user: RegistrationDraft(),
                validator: StubRegistrationUseCase(),
                onNextTapped: { _ in }
            )
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
