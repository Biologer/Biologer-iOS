import SwiftUI

struct RegistrationPersonalInfoScreen: View {
    @ObservedObject private var viewModel: RegistrationFlowViewModel
    private let onNext: () -> Void

    init(
        viewModel: RegistrationFlowViewModel,
        onNext: @escaping () -> Void
    ) {
        self.viewModel = viewModel
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
                            get: { viewModel.draft.firstName },
                            set: viewModel.updateFirstName
                        ),
                        placeholder: "Register.one.tf.name.placeholder".localized,
                        errorText: viewModel.firstNameError,
                        systemImage: "person",
                        textContentType: .givenName
                    )

                    AuthorizationTextField(
                        text: Binding(
                            get: { viewModel.draft.lastName },
                            set: viewModel.updateLastName
                        ),
                        placeholder: "Register.one.tf.surname.placeholder".localized,
                        errorText: viewModel.lastNameError,
                        systemImage: "person",
                        textContentType: .familyName
                    )

                    AuthorizationTextField(
                        text: Binding(
                            get: { viewModel.draft.institution },
                            set: viewModel.updateInstitution
                        ),
                        placeholder: "Register.one.tf.institution.placeholder".localized,
                        systemImage: "building.2",
                        textContentType: .organizationName
                    )
                }

                Button {
                    guard viewModel.validatePersonalInfo() else { return }
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
