import SwiftUI

struct BiologerIconBadge: View {
    let systemImage: String
    var tint = BiologerColors.accent
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
