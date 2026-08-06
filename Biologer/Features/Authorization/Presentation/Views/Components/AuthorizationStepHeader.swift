import SwiftUI

struct AuthorizationStepHeader: View {
    let step: Int
    let totalSteps: Int
    let systemImage: String

    var body: some View {
        VStack(spacing: BiologerSpacing.regular) {
            BiologerIconBadge(
                systemImage: systemImage,
                size: 62
            )

            HStack(spacing: BiologerSpacing.xSmall) {
                ForEach(Array(1...totalSteps), id: \.self) { index in
                    Capsule()
                        .fill(
                            index <= step
                                ? BiologerColors.brandStrong
                                : BiologerColors.iconBackground
                        )
                        .frame(height: 5)
                }
            }

            Text("\(step) / \(totalSteps)")
                .font(.caption.weight(.semibold))
                .foregroundColor(BiologerColors.sectionTitle)
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }
}
