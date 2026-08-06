import SwiftUI

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
                Text("ListOfFindings.empty.title".localized)
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
            "ListOfFindings.empty.title".localized
        case .uploaded:
            "ListOfFindings.filter.empty.uploaded".localized
        case .pending:
            "ListOfFindings.filter.empty.pending".localized
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
