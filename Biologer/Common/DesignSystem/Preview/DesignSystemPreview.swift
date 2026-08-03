import SwiftUI

struct BiologerDesignSystem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                BiologerDesignSystemCatalog()
            }
            .previewDisplayName("Design System")

            NavigationStack {
                BiologerDesignSystemCatalog()
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Design System - Dark")

            NavigationStack {
                BiologerDesignSystemCatalog()
            }
            .environment(\.sizeCategory, .accessibilityExtraLarge)
            .previewDisplayName("Design System - Dynamic Type")
        }
    }
}

private struct BiologerDesignSystemCatalog: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BiologerSpacing.xLarge) {
                paletteSection
                componentSection
                buttonSection
            }
            .padding(BiologerSpacing.regular)
        }
        .biologerPageBackground()
        .navigationTitle("Biologer UI")
        .tint(BiologerColors.accent)
    }

    private var paletteSection: some View {
        VStack(alignment: .leading, spacing: BiologerSpacing.small) {
            BiologerSectionHeader(
                title: "Palette",
                systemImage: "paintpalette"
            )

            VStack(spacing: BiologerSpacing.xSmall) {
                colorSwatch("Accent #7BBC4A", color: BiologerColors.brandAccent)
                colorSwatch("Strong #4F7A2E", color: BiologerColors.brandStrong)
                colorSwatch("Soft #DDEECF", color: BiologerColors.brandSoft)
                colorSwatch("Canvas #F4F0E6", color: BiologerColors.brandCanvas)
                colorSwatch("Ink #2F3A2C", color: BiologerColors.brandInk)
            }
            .padding(BiologerSpacing.regular)
            .biologerCard()
        }
    }

    private var componentSection: some View {
        VStack(alignment: .leading, spacing: BiologerSpacing.small) {
            BiologerSectionHeader(
                title: "Components",
                systemImage: "square.grid.2x2"
            )

            HStack(spacing: BiologerSpacing.regular) {
                BiologerIconBadge(systemImage: "leaf.fill")
                BiologerIconBadge(systemImage: "photo.fill", size: 48)

                VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
                    Text("Surface card")
                        .font(.body.weight(.semibold))
                        .foregroundColor(BiologerColors.textPrimary)
                    Text("Shared visual building blocks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer(minLength: 0)
            }
            .padding(BiologerSpacing.regular)
            .biologerCard(isSelected: true)
        }
    }

    private var buttonSection: some View {
        VStack(alignment: .leading, spacing: BiologerSpacing.small) {
            BiologerSectionHeader(
                title: "Actions",
                systemImage: "hand.tap"
            )

            VStack(spacing: BiologerSpacing.small) {
                Button("Primary action") {}
                    .buttonStyle(BiologerActionButtonStyle())

                Button("Secondary action") {}
                    .buttonStyle(
                        BiologerActionButtonStyle(isFilled: false)
                    )

                Button("Destructive action") {}
                    .buttonStyle(
                        BiologerActionButtonStyle(role: .destructive)
                    )
            }
        }
    }

    private func colorSwatch(_ title: String, color: Color) -> some View {
        HStack(spacing: BiologerSpacing.small) {
            RoundedRectangle(cornerRadius: BiologerRadius.icon)
                .fill(color)
                .frame(width: 44, height: 44)

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(BiologerColors.textPrimary)

            Spacer(minLength: 0)
        }
    }
}
