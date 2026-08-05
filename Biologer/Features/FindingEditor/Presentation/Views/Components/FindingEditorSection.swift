import SwiftUI

struct FindingEditorSection<Content: View>: View {
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
            BiologerSectionHeader(title: title, systemImage: systemImage)

            VStack(alignment: .leading, spacing: BiologerSpacing.regular) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(BiologerSpacing.regular)
            .biologerCard()
        }
    }
}

struct FindingEditorField: View {
    let title: String
    let systemImage: String
    let prompt: String
    @Binding var text: String
    var axis: Axis = .horizontal

    var body: some View {
        VStack(alignment: .leading, spacing: BiologerSpacing.xSmall) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundColor(BiologerColors.sectionTitle)

            TextField(prompt, text: $text, axis: axis)
                .foregroundColor(BiologerColors.textPrimary)
                .lineLimit(axis == .vertical ? 3...7 : 1...1)
                .padding(.horizontal, BiologerSpacing.small)
                .padding(.vertical, BiologerSpacing.small)
                .background(
                    BiologerColors.pageBackground,
                    in: RoundedRectangle(
                        cornerRadius: BiologerRadius.control,
                        style: .continuous
                    )
                )
                .overlay {
                    RoundedRectangle(
                        cornerRadius: BiologerRadius.control,
                        style: .continuous
                    )
                    .stroke(BiologerColors.brandStrong.opacity(0.14), lineWidth: 1)
                }
        }
    }
}

struct FindingEditorCounter: View {
    let title: String
    let systemImage: String
    @Binding var value: Int
    var minimum = 0

    var body: some View {
        HStack(spacing: BiologerSpacing.small) {
            BiologerIconBadge(systemImage: systemImage, size: 32)

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(BiologerColors.textPrimary)

            Spacer(minLength: BiologerSpacing.xSmall)

            Button {
                value = max(minimum, value - 1)
            } label: {
                Image(systemName: "minus")
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
            .foregroundColor(BiologerColors.accent)
            .background(BiologerColors.iconBackground, in: Circle())
            .disabled(value <= minimum)

            Text(String(value))
                .font(.body.monospacedDigit().weight(.semibold))
                .foregroundColor(BiologerColors.textPrimary)
                .frame(minWidth: 28)

            Button {
                value += 1
            } label: {
                Image(systemName: "plus")
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
            .foregroundColor(.white)
            .background(BiologerColors.accent, in: Circle())
        }
    }
}
