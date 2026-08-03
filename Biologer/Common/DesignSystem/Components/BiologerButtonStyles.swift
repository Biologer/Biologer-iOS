import SwiftUI

enum BiologerActionRole {
    case primary
    case destructive
}

struct BiologerActionButtonStyle: ButtonStyle {
    let role: BiologerActionRole
    let isFilled: Bool

    init(
        role: BiologerActionRole = .primary,
        isFilled: Bool = true
    ) {
        self.role = role
        self.isFilled = isFilled
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BiologerSpacing.small)
            .background(
                isFilled
                    ? tint.opacity(configuration.isPressed ? 0.78 : 1)
                    : .clear,
                in: RoundedRectangle(
                    cornerRadius: BiologerRadius.control,
                    style: .continuous
                )
            )
            .overlay {
                if !isFilled {
                    RoundedRectangle(
                        cornerRadius: BiologerRadius.control,
                        style: .continuous
                    )
                    .stroke(
                        tint.opacity(configuration.isPressed ? 0.6 : 1),
                        lineWidth: 1.5
                    )
                }
            }
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }

    private var tint: Color {
        switch role {
        case .primary:
            BiologerColors.primaryActionBackground
        case .destructive:
            BiologerColors.destructive
        }
    }

    private var foregroundColor: Color {
        isFilled ? BiologerColors.primaryActionForeground : tint
    }
}
