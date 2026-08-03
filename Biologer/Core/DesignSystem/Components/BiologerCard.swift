import SwiftUI

private struct BiologerCardModifier: ViewModifier {
    let isSelected: Bool
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                isSelected
                    ? BiologerColors.selectedSurface
                    : BiologerColors.surface,
                in: RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .stroke(
                    isSelected
                        ? BiologerColors.accent.opacity(0.8)
                        : BiologerColors.brandStrong.opacity(0.08),
                    lineWidth: isSelected ? 1.5 : 1
                )
            }
            .shadow(color: .black.opacity(0.035), radius: 8, y: 3)
    }
}

extension View {
    func biologerCard(
        isSelected: Bool = false,
        cornerRadius: CGFloat = BiologerRadius.card
    ) -> some View {
        modifier(
            BiologerCardModifier(
                isSelected: isSelected,
                cornerRadius: cornerRadius
            )
        )
    }

    func biologerPageBackground() -> some View {
        background(BiologerColors.pageBackground.ignoresSafeArea())
    }
}
