import SwiftUI

struct BiologerSectionHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title.uppercased(), systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundColor(BiologerColors.sectionTitle)
            .tracking(0.5)
            .padding(.horizontal, BiologerSpacing.xxSmall)
    }
}
