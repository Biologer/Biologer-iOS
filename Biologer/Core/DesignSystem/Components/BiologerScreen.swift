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
