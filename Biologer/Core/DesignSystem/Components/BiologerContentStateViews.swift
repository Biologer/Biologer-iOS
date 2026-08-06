import SwiftUI

struct BiologerLoadingStateView: View {
    let message: String
    var fillsAvailableSpace = true

    var body: some View {
        VStack(spacing: BiologerSpacing.regular) {
            ProgressView()
                .controlSize(.large)
                .tint(BiologerColors.accent)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: fillsAvailableSpace ? .infinity : nil
        )
        .padding(.top, fillsAvailableSpace ? 0 : BiologerSpacing.xxLarge)
    }
}

enum BiologerMessageStateStyle {
    case standard
    case failure
}

struct BiologerMessageStateView: View {
    let systemImage: String
    let title: String
    let message: String?
    let actionTitle: String?
    let style: BiologerMessageStateStyle
    let fillsAvailableSpace: Bool
    let action: (() -> Void)?

    init(
        systemImage: String,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        style: BiologerMessageStateStyle = .standard,
        fillsAvailableSpace: Bool = true,
        action: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.style = style
        self.fillsAvailableSpace = fillsAvailableSpace
        self.action = action
    }

    var body: some View {
        VStack(spacing: BiologerSpacing.regular) {
            if fillsAvailableSpace {
                Spacer()
            }

            BiologerIconBadge(
                systemImage: systemImage,
                tint: iconTint,
                backgroundColor: iconBackground,
                size: 64
            )

            VStack(spacing: BiologerSpacing.xSmall) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(BiologerColors.textPrimary)
                    .multilineTextAlignment(.center)

                if let message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(BiologerActionButtonStyle())
                    .frame(maxWidth: 260)
            }

            if fillsAvailableSpace {
                Spacer()
                Spacer()
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: fillsAvailableSpace ? .infinity : nil
        )
        .padding(.horizontal, BiologerSpacing.xLarge)
        .padding(.vertical, fillsAvailableSpace ? BiologerSpacing.xLarge : 0)
        .padding(.top, fillsAvailableSpace ? 0 : BiologerSpacing.xxLarge)
    }

    private var iconTint: Color {
        switch style {
        case .standard:
            BiologerColors.brandStrong
        case .failure:
            BiologerColors.destructive
        }
    }

    private var iconBackground: Color {
        switch style {
        case .standard:
            BiologerColors.iconBackground
        case .failure:
            BiologerColors.destructive.opacity(0.1)
        }
    }
}
