import SwiftUI

private struct BiologerHeroCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [
                        BiologerColors.brandStrong,
                        BiologerColors.accent
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
            )
            .shadow(
                color: BiologerColors.brandStrong.opacity(0.24),
                radius: 12,
                y: 6
            )
    }
}

extension View {
    func biologerHeroCard(
        cornerRadius: CGFloat = BiologerRadius.hero
    ) -> some View {
        modifier(BiologerHeroCardModifier(cornerRadius: cornerRadius))
    }
}
