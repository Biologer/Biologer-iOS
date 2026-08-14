import SwiftUI

/// A reusable progress summary that leaves feature-specific details to its caller.
struct BiologerProgressSummary: View {
    let title: String
    let progress: Double
    let valueText: String
    let showsActivityIndicator: Bool

    init(
        title: String,
        progress: Double,
        valueText: String,
        showsActivityIndicator: Bool = false
    ) {
        self.title = title
        self.progress = progress
        self.valueText = valueText
        self.showsActivityIndicator = showsActivityIndicator
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BiologerSpacing.small) {
            HStack(spacing: BiologerSpacing.small) {
                if showsActivityIndicator {
                    BiologerActivityIndicator()
                }

                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundColor(BiologerColors.textPrimary)

                Spacer(minLength: BiologerSpacing.xSmall)

                Text(valueText)
                    .font(.subheadline.monospacedDigit().weight(.medium))
                    .foregroundColor(.secondary)
            }

            ProgressView(value: normalizedProgress)
                .tint(BiologerColors.accent)
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(valueText)
    }

    private var normalizedProgress: Double {
        min(max(progress, 0), 1)
    }
}

#Preview("BiologerProgressSummary") {
    BiologerProgressSummary(
        title: "Downloading",
        progress: 0.43,
        valueText: "43%",
        showsActivityIndicator: true
    )
    .padding(BiologerSpacing.regular)
    .biologerCard()
    .padding(BiologerSpacing.xLarge)
    .biologerPageBackground()
}
