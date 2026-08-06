import SwiftUI

enum BiologerResultStyle: Equatable {
    case success
    case failure
}

struct BiologerResultSheet: View {
    let style: BiologerResultStyle
    let title: String
    let message: String
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: BiologerSpacing.large) {
            BiologerIconBadge(
                systemImage: systemImage,
                tint: tint,
                backgroundColor: backgroundColor,
                size: 68
            )

            VStack(spacing: BiologerSpacing.xSmall) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundColor(BiologerColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button("Common.btn.ok".localized, action: onConfirm)
                .buttonStyle(
                    BiologerActionButtonStyle(
                        role: style == .success ? .primary : .destructive
                    )
                )
        }
        .padding(BiologerSpacing.xLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BiologerColors.pageBackground.ignoresSafeArea())
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(BiologerColors.pageBackground)
    }

    private var systemImage: String {
        style == .success
            ? "checkmark.circle.fill"
            : "exclamationmark.triangle.fill"
    }

    private var tint: Color {
        style == .success
            ? BiologerColors.primaryActionBackground
            : BiologerColors.destructive
    }

    private var backgroundColor: Color {
        style == .success
            ? BiologerColors.iconBackground
            : BiologerColors.destructive.opacity(0.1)
    }
}

#Preview("BiologerResultSheet - Success") {
    BiologerResultSheet(
        style: .success,
        title: "FindingEditor.saveSuccess.title".localized,
        message: "FindingEditor.saveSuccess.created".localized,
        onConfirm: {}
    )
}

#Preview("BiologerResultSheet - Failure") {
    BiologerResultSheet(
        style: .failure,
        title: "API.lb.error".localized,
        message: "ListOfFindings.loadError.message".localized,
        onConfirm: {}
    )
}
