import SwiftUI

private struct BiologerNavigationBarModifier: ViewModifier {
    let title: String?
    let onBack: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(onBack != nil)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(BiologerColors.pageBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                if let onBack {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.body.weight(.semibold))
                                .foregroundColor(BiologerColors.sectionTitle)
                        }
                    }
                }

                if let title {
                    ToolbarItem(placement: .principal) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(BiologerColors.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .tint(BiologerColors.accent)
    }
}

extension View {
    func biologerNavigationBar(
        title: String? = nil,
        onBack: (() -> Void)? = nil
    ) -> some View {
        modifier(
            BiologerNavigationBarModifier(
                title: title,
                onBack: onBack
            )
        )
    }
}
