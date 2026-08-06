import SwiftUI

struct RegistrationPersonalInfoScreen: View {
    @ObservedObject private var loader: RegistrationPersonalInfoViewModel
    private let onNext: () -> Void

    init(
        loader: RegistrationPersonalInfoViewModel,
        onNext: @escaping () -> Void
    ) {
        self.loader = loader
        self.onNext = onNext
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

                Button {
                    guard loader.nextButtonTapped() else { return }
                    onNext()
                } label: {
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
