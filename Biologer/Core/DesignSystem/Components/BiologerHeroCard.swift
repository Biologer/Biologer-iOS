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

#Preview("BiologerHeroCard") {
    HStack(spacing: BiologerSpacing.regular) {
        Image(systemName: "leaf.fill")
            .font(.title)
            .foregroundColor(.white)

        Text("Findings.title".localized)
            .font(.title3.weight(.semibold))
            .foregroundColor(.white)

        Spacer()
    }
    .padding(BiologerSpacing.large)
    .biologerHeroCard()
    .padding(BiologerSpacing.xLarge)
    .biologerPageBackground()
}
