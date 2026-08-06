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

        return BiologerSelectionCard(
            title: environment.title,
            subtitle: environment.env.host,
            isSelected: isSelected,
            verticalAlignment: .center,
            subtitleFont: .caption,
            subtitleLineLimit: 1,
            indicatorTopPadding: 0,
            action: { select(environment) }
        ) {
            Image(environment.image)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
        }
        .allowsHitTesting(!isSelectionLocked)
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
