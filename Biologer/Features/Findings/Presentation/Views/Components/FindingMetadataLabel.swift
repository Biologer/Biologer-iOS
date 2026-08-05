import SwiftUI

struct FindingMetadataLabel: View {
    let title: String
    let systemImage: String
    var spacing: CGFloat = BiologerSpacing.xxSmall

    var body: some View {
        HStack(spacing: spacing) {
            Image(systemName: systemImage)
            Text(title)
        }
    }
}
