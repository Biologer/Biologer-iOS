import SwiftUI

struct AuthorizationBrandHeader: View {
    var environmentImage: String?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image("biologer_logo_icon")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300, maxHeight: 100)
                .padding(.horizontal, BiologerSpacing.regular)
                .padding(.vertical, BiologerSpacing.small)
        }
    }
}
