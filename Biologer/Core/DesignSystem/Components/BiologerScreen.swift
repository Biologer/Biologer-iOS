import SwiftUI

private struct BiologerScreenModifier: ViewModifier {
    let title: String
    let titleDisplayMode: NavigationBarItem.TitleDisplayMode

    func body(content: Content) -> some View {
        content
            .biologerPageBackground()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(titleDisplayMode)
            .tint(BiologerColors.accent)
    }
}

extension View {
    func biologerScreen(
        title: String,
        titleDisplayMode: NavigationBarItem.TitleDisplayMode = .inline
    ) -> some View {
        modifier(
            BiologerScreenModifier(
                title: title,
                titleDisplayMode: titleDisplayMode
            )
        )
    }
}

#Preview("BiologerScreen - Inline") {
    NavigationStack {
        VStack(spacing: BiologerSpacing.regular) {
            BiologerIconBadge(systemImage: "leaf.fill", size: 64)
            Text("Findings.title".localized)
                .font(.title3.weight(.semibold))
                .foregroundColor(BiologerColors.textPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .biologerScreen(title: "Findings.title".localized)
    }
}

#Preview("BiologerScreen - Large") {
    NavigationStack {
        VStack(spacing: BiologerSpacing.regular) {
            BiologerIconBadge(systemImage: "leaf.fill", size: 64)
            Text("Findings.title".localized)
                .font(.title3.weight(.semibold))
                .foregroundColor(BiologerColors.textPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .biologerScreen(
            title: "Findings.title".localized,
            titleDisplayMode: .large
        )
    }
}
