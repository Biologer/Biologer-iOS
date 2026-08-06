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
