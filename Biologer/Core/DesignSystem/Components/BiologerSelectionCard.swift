import SwiftUI

struct BiologerSelectionCard<Leading: View>: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let verticalAlignment: VerticalAlignment
    let titleFont: Font
    let subtitleFont: Font
    let subtitleLineLimit: Int?
    let indicatorTopPadding: CGFloat
    let action: () -> Void

    private let leading: Leading

    init(
        title: String,
        subtitle: String? = nil,
        isSelected: Bool,
        verticalAlignment: VerticalAlignment = .top,
        titleFont: Font = .body.weight(.semibold),
        subtitleFont: Font = .subheadline,
        subtitleLineLimit: Int? = nil,
        indicatorTopPadding: CGFloat = BiologerSpacing.xxSmall,
        action: @escaping () -> Void,
        @ViewBuilder leading: () -> Leading
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.verticalAlignment = verticalAlignment
        self.titleFont = titleFont
        self.subtitleFont = subtitleFont
        self.subtitleLineLimit = subtitleLineLimit
        self.indicatorTopPadding = indicatorTopPadding
        self.action = action
        self.leading = leading()
    }

    var body: some View {
        Button(action: action) {
            HStack(
                alignment: verticalAlignment,
                spacing: BiologerSpacing.small
            ) {
                leading

                VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
                    Text(title)
                        .font(titleFont)
                        .foregroundColor(BiologerColors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    if let subtitle {
                        Text(subtitle)
                            .font(subtitleFont)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(subtitleLineLimit)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: BiologerSpacing.xSmall)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(
                        isSelected
                            ? BiologerColors.accent
                            : Color(uiColor: .tertiaryLabel)
                    )
                    .padding(.top, indicatorTopPadding)
            }
            .padding(BiologerSpacing.regular)
            .contentShape(Rectangle())
            .biologerCard(isSelected: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("BiologerSelectionCard - Selected") {
    BiologerSelectionCard(
        title: "Settings.lb.dataLicense.title".localized,
        subtitle: "Register.three.lb.description".localized,
        isSelected: true,
        action: {}
    ) {
        BiologerIconBadge(systemImage: "doc.text")
    }
    .padding(BiologerSpacing.xLarge)
    .biologerPageBackground()
}

#Preview("BiologerSelectionCard - Unselected") {
    BiologerSelectionCard(
        title: "Settings.lb.imageLicense.title".localized,
        isSelected: false,
        verticalAlignment: .center,
        indicatorTopPadding: 0,
        action: {}
    ) {
        BiologerIconBadge(systemImage: "photo")
    }
    .padding(BiologerSpacing.xLarge)
    .biologerPageBackground()
}
