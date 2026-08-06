import SwiftUI

struct AuthorizationNavigationCard: View {
    let title: String
    let subtitle: String?
    let systemImage: String
    let action: () -> Void

    init(
        title: String,
        subtitle: String? = nil,
        systemImage: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: BiologerSpacing.small) {
                BiologerIconBadge(systemImage: systemImage)

                VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
                    if let subtitle {
                        Text(subtitle.uppercased())
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(BiologerColors.sectionTitle)
                            .tracking(0.4)
                    }

                    Text(title)
                        .font(.body.weight(.medium))
                        .foregroundColor(BiologerColors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: BiologerSpacing.xSmall)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(Color(uiColor: .tertiaryLabel))
            }
            .padding(BiologerSpacing.regular)
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity)
            .biologerCard()
        }
        .buttonStyle(.plain)
    }
}
