import SwiftUI

struct SettingsSectionHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title.uppercased(), systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundColor(SettingsColorPalette.sectionTitle)
            .tracking(0.5)
            .padding(.horizontal, 4)
    }
}

struct SettingsIconBadge: View {
    let systemImage: String
    var tint = SettingsColorPalette.primary
    var backgroundColor = SettingsColorPalette.iconBackground
    var size: CGFloat = 34

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.46, weight: .semibold))
            .foregroundColor(tint)
            .frame(width: size, height: size)
            .background(
                backgroundColor,
                in: RoundedRectangle(cornerRadius: size * 0.29, style: .continuous)
            )
    }
}

struct SettingsActionButtonStyle: ButtonStyle {
    let tint: Color
    var isFilled = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundColor(isFilled ? .white : tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                isFilled ? tint.opacity(configuration.isPressed ? 0.78 : 1) : .clear,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay {
                if !isFilled {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(tint.opacity(configuration.isPressed ? 0.6 : 1), lineWidth: 1.5)
                }
            }
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

private struct SettingsCardModifier: ViewModifier {
    let isSelected: Bool
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                isSelected
                    ? SettingsColorPalette.selectedSurface
                    : SettingsColorPalette.surface,
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        isSelected
                            ? SettingsColorPalette.primary.opacity(0.8)
                            : SettingsColorPalette.forest.opacity(0.08),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
            .shadow(color: .black.opacity(0.035), radius: 8, y: 3)
    }
}

extension View {
    func settingsCard(
        isSelected: Bool = false,
        cornerRadius: CGFloat = 18
    ) -> some View {
        modifier(
            SettingsCardModifier(
                isSelected: isSelected,
                cornerRadius: cornerRadius
            )
        )
    }

    func settingsPageBackground() -> some View {
        background(SettingsColorPalette.pageBackground.ignoresSafeArea())
    }
}
