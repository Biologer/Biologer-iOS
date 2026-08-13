import SwiftUI

struct AppSessionPreparationFailureView: View {
    let message: String
    let onRetry: () -> Void
    let onLogout: () -> Void

    var body: some View {
        VStack(spacing: BiologerSpacing.regular) {
            Spacer()

            BiologerIconBadge(
                systemImage: "exclamationmark.arrow.triangle.2.circlepath",
                tint: BiologerColors.destructive,
                backgroundColor: BiologerColors.destructive.opacity(0.1),
                size: 68
            )

            VStack(spacing: BiologerSpacing.xSmall) {
                Text("API.lb.error".localized)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(BiologerColors.textPrimary)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: BiologerSpacing.small) {
                Button("TaxonSync.action.retry".localized, action: onRetry)
                    .buttonStyle(BiologerActionButtonStyle())

                Button(
                    "Logout.btn.logout".localized,
                    role: .destructive,
                    action: onLogout
                )
                .buttonStyle(
                    BiologerActionButtonStyle(
                        role: .destructive,
                        isFilled: false
                    )
                )
            }
            .frame(maxWidth: 280)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, BiologerSpacing.xLarge)
        .biologerPageBackground()
    }
}

#Preview("Session preparation failure") {
    AppSessionPreparationFailureView(
        message: "Unable to prepare the required application data.",
        onRetry: {},
        onLogout: {}
    )
}
