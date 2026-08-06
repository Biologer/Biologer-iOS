import SwiftUI

struct EnvironmentSelectionScreen: View {
    @Binding var selectedEnvironment: EnvironmentViewModel
    @State private var environments: [EnvironmentViewModel]
    @State private var isSelectionLocked = false

    private let close: () -> Void

    init(
        selectedEnvironment: Binding<EnvironmentViewModel>,
        environments: [EnvironmentViewModel],
        close: @escaping () -> Void
    ) {
        _selectedEnvironment = selectedEnvironment
        _environments = State(initialValue: environments)
        self.close = close
        updateSelectedEnvironment()
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: BiologerSpacing.small) {
                BiologerIconBadge(
                    systemImage: "globe.europe.africa.fill",
                    size: 64
                )
                .padding(.vertical, BiologerSpacing.small)

                ForEach(environments, id: \.id) { environment in
                    environmentCard(environment)
                }
            }
            .padding(.horizontal, BiologerSpacing.regular)
            .padding(.bottom, BiologerSpacing.xxLarge)
        }
        .biologerPageBackground()
        .navigationBarBackButtonHidden(true)
        .onChange(of: selectedEnvironment) { _ in
            updateSelectedEnvironment()
        }
    }

    private func environmentCard(_ environment: EnvironmentViewModel) -> some View {
        let isSelected = environment.id == selectedEnvironment.id

        return Button(action: { select(environment) }) {
            HStack(spacing: BiologerSpacing.regular) {
                Image(environment.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
                    Text(environment.title)
                        .font(.body.weight(.semibold))
                        .foregroundColor(BiologerColors.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text(environment.env.host)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: BiologerSpacing.xSmall)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(
                        isSelected
                            ? BiologerColors.accent
                            : Color(uiColor: .tertiaryLabel)
                    )
            }
            .padding(BiologerSpacing.regular)
            .contentShape(Rectangle())
            .biologerCard(isSelected: isSelected)
        }
        .buttonStyle(.plain)
        .disabled(isSelectionLocked)
    }

    private func select(_ environment: EnvironmentViewModel) {
        guard !isSelectionLocked else { return }
        isSelectionLocked = true

        withAnimation(.easeInOut(duration: 0.18)) {
            selectedEnvironment = environment
            updateSelectedEnvironment()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            close()
        }
    }

    private func updateSelectedEnvironment() {
        for (index, environment) in environments.enumerated() {
            environments[index].changeIsSelected(
                value: environment.id == selectedEnvironment.id
            )
        }
    }
}
