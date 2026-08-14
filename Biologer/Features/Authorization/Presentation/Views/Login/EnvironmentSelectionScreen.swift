import SwiftUI

struct EnvironmentSelectionScreen: View {
    @State private var isSelectionLocked = false

    private let selectedEnvironment: EnvironmentOption
    private let environments: [EnvironmentOption]
    private let onSelect: (EnvironmentOption) -> Bool
    private let close: () -> Void

    init(
        selectedEnvironment: EnvironmentOption,
        environments: [EnvironmentOption],
        onSelect: @escaping (EnvironmentOption) -> Bool,
        close: @escaping () -> Void
    ) {
        self.selectedEnvironment = selectedEnvironment
        self.environments = environments
        self.onSelect = onSelect
        self.close = close
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
    }

    private func environmentCard(_ environment: EnvironmentOption) -> some View {
        let isSelected = environment.id == selectedEnvironment.id

        return BiologerSelectionCard(
            title: environment.title,
            isSelected: isSelected,
            verticalAlignment: .center,
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

    private func select(_ environment: EnvironmentOption) {
        guard !isSelectionLocked else { return }
        isSelectionLocked = true

        let didSelect = withAnimation(.easeInOut(duration: 0.18)) {
            onSelect(environment)
        }
        guard didSelect else {
            isSelectionLocked = false
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            close()
        }
    }
}
