import SwiftUI

struct BiologerIconBadge: View {
    let systemImage: String
    var tint = BiologerColors.brandStrong
    var backgroundColor = BiologerColors.iconBackground
    var size: CGFloat = 34

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.46, weight: .semibold))
            .foregroundColor(tint)
            .frame(width: size, height: size)
            .background(
                backgroundColor,
                in: RoundedRectangle(
                    cornerRadius: size * 0.29,
                    style: .continuous
                )
            )
    }
}

#Preview("BiologerIconBadge - Sizes") {
    HStack(spacing: BiologerSpacing.regular) {
        BiologerIconBadge(systemImage: "leaf.fill")
        BiologerIconBadge(systemImage: "photo.fill", size: 48)
        BiologerIconBadge(systemImage: "location.fill", size: 64)
    }
    .padding(BiologerSpacing.xLarge)
    .biologerPageBackground()
}

#Preview("BiologerIconBadge - Failure") {
    BiologerIconBadge(
        systemImage: "exclamationmark.triangle.fill",
        tint: BiologerColors.destructive,
        backgroundColor: BiologerColors.destructive.opacity(0.1),
        size: 64
    )
    .padding(BiologerSpacing.xLarge)
    .biologerPageBackground()
}
