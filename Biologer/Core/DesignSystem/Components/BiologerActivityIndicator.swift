import SwiftUI

struct BiologerActivityIndicator: View {
    enum Size {
        case compact
        case regular
        case large
    }

    enum Tone {
        case accent
        case inverse
    }

    var size: Size = .regular
    var tone: Tone = .accent

    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .controlSize(controlSize)
            .tint(tintColor)
    }

    private var controlSize: ControlSize {
        switch size {
        case .compact:
            .small
        case .regular:
            .regular
        case .large:
            .large
        }
    }

    private var tintColor: Color {
        switch tone {
        case .accent:
            BiologerColors.accent
        case .inverse:
            .white
        }
    }
}

#Preview("BiologerActivityIndicator - Sizes") {
    HStack(spacing: BiologerSpacing.xLarge) {
        BiologerActivityIndicator(size: .compact)
        BiologerActivityIndicator()
        BiologerActivityIndicator(size: .large)
    }
    .padding(BiologerSpacing.xLarge)
    .biologerPageBackground()
}

#Preview("BiologerActivityIndicator - Inverse") {
    HStack(spacing: BiologerSpacing.xLarge) {
        BiologerActivityIndicator(
            size: .compact,
            tone: .inverse
        )
        BiologerActivityIndicator(
            size: .regular,
            tone: .inverse
        )
        BiologerActivityIndicator(
            size: .large,
            tone: .inverse
        )
    }
    .padding(BiologerSpacing.xLarge)
    .background(BiologerColors.brandStrong)
}
