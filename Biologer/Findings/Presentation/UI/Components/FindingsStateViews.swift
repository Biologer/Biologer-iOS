import SwiftUI

struct FindingsLoadingView: View {
    var body: some View {
        VStack(spacing: BiologerSpacing.regular) {
            ProgressView()
                .controlSize(.large)
                .tint(BiologerColors.accent)

            Text("ListOfFindingsV2.loading".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FindingsEmptyView: View {
    var body: some View {
        VStack(spacing: BiologerSpacing.large) {
            Spacer()

            ZStack {
                Circle()
                    .fill(BiologerColors.iconBackground)
                    .frame(width: 96, height: 96)

                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(BiologerColors.brandStrong)
            }

            VStack(spacing: BiologerSpacing.xSmall) {
                Text("ListOfFindingsV2.empty.title".localized)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(BiologerColors.textPrimary)

                Text("ListOfFindings.noFindings.title".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, BiologerSpacing.xLarge)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(BiologerSpacing.regular)
    }
}

struct FindingsFailureView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: BiologerSpacing.regular) {
            Spacer()

            BiologerIconBadge(
                systemImage: "exclamationmark.arrow.triangle.2.circlepath",
                tint: BiologerColors.destructive,
                backgroundColor: BiologerColors.destructive.opacity(0.1),
                size: 64
            )

            VStack(spacing: BiologerSpacing.xSmall) {
                Text("ListOfFindingsV2.loadError.title".localized)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(BiologerColors.textPrimary)

                Text("ListOfFindingsV2.loadError.message".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(
                "ListOfFindingsV2.retry".localized,
                action: onRetry
            )
            .buttonStyle(BiologerActionButtonStyle())
            .frame(maxWidth: 260)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(BiologerSpacing.xLarge)
    }
}

struct FindingsFilteredEmptyView: View {
    let filter: FindingsListFilter

    var body: some View {
        VStack(spacing: BiologerSpacing.small) {
            BiologerIconBadge(
                systemImage: systemImage,
                size: 52
            )

            Text(message)
                .font(.subheadline.weight(.medium))
                .foregroundColor(BiologerColors.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(BiologerSpacing.xLarge)
        .biologerCard()
    }

    private var message: String {
        switch filter {
        case .all:
            "ListOfFindingsV2.empty.title".localized
        case .uploaded:
            "ListOfFindingsV2.filter.empty.uploaded".localized
        case .pending:
            "ListOfFindingsV2.filter.empty.pending".localized
        }
    }

    private var systemImage: String {
        switch filter {
        case .all:
            "leaf"
        case .uploaded:
            "checkmark.circle"
        case .pending:
            "icloud.and.arrow.up"
        }
    }
}
