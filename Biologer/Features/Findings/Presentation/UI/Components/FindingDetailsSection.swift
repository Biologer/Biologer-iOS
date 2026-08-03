import SwiftUI

struct FindingDetailsSection<Content: View>: View {
    let title: String
    let systemImage: String
    private let content: Content

    init(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BiologerSpacing.xSmall) {
            BiologerSectionHeader(
                title: title,
                systemImage: systemImage
            )

            VStack(spacing: 0) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .biologerCard()
        }
    }
}

struct FindingDetailsInfoRow: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: BiologerSpacing.small) {
            BiologerIconBadge(
                systemImage: systemImage,
                size: 32
            )

            VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.body.weight(.medium))
                    .foregroundColor(BiologerColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(BiologerSpacing.regular)
        .accessibilityElement(children: .combine)
    }
}

struct FindingDetailsTextRow: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: BiologerSpacing.small) {
            BiologerIconBadge(
                systemImage: systemImage,
                size: 32
            )

            VStack(alignment: .leading, spacing: BiologerSpacing.xSmall) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(BiologerColors.sectionTitle)

                Text(value)
                    .font(.body)
                    .foregroundColor(BiologerColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(BiologerSpacing.regular)
        .accessibilityElement(children: .combine)
    }
}

struct FindingDetailsDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 60)
    }
}
