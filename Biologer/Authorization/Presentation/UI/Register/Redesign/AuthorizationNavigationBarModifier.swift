import SwiftUI

private struct AuthorizationNavigationBarModifier: ViewModifier {
    let title: String?
    let onBack: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let onBack {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: onBack) {
                            Image("back_arrow")
                                .foregroundColor(Color(.darkText))
                        }
                    }
                }

                if let title {
                    ToolbarItem(placement: .principal) {
                        Text(title)
                            .font(.system(size: navigationBarTitleSize, weight: .bold))
                            .foregroundColor(Color(.darkText))
                            .multilineTextAlignment(.center)
                    }
                }
            }
    }
}

extension View {
    func authorizationNavigationBar(
        title: String? = nil,
        onBack: (() -> Void)? = nil
    ) -> some View {
        modifier(AuthorizationNavigationBarModifier(title: title, onBack: onBack))
    }
}
