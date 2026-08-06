import SwiftUI

struct BiologerLoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()

            BiologerActivityIndicator(size: .large)
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

#Preview("BiologerLoadingOverlay") {
    VStack(spacing: BiologerSpacing.regular) {
        BiologerIconBadge(systemImage: "leaf.fill", size: 64)
        Text("Findings.title".localized)
            .font(.title3.weight(.semibold))
            .foregroundColor(BiologerColors.textPrimary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .biologerPageBackground()
    .biologerLoadingOverlay(isPresented: true)
}

extension View {
    func biologerLoadingOverlay(isPresented: Bool) -> some View {
        modifier(BiologerLoadingOverlayModifier(isPresented: isPresented))
    }
}
