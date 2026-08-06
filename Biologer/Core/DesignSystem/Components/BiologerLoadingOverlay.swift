import SwiftUI

struct BiologerLoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()

            ProgressView()
                .controlSize(.large)
                .tint(BiologerColors.primaryActionBackground)
                .padding(BiologerSpacing.xLarge)
                .background(BiologerColors.surface, in: Circle())
                .shadow(color: .black.opacity(0.12), radius: 12, y: 5)
        }
    }
}

private struct BiologerLoadingOverlayModifier: ViewModifier {
    let isPresented: Bool

    func body(content: Content) -> some View {
        content
            .disabled(isPresented)
            .overlay {
                if isPresented {
                    BiologerLoadingOverlay()
                }
            }
    }
}

extension View {
    func biologerLoadingOverlay(isPresented: Bool) -> some View {
        modifier(BiologerLoadingOverlayModifier(isPresented: isPresented))
    }
}
