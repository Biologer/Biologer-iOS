import SwiftUI

struct LicenseSelectionScreen: View {
    @Binding private var selectedID: Int
    @State private var isSelectionLocked = false

    private let items: [LicenseOption]
    private let onSelectionChanged: ((Int) -> Void)?

    init(
        selectedID: Binding<Int>,
        items: [LicenseOption],
        onSelectionChanged: ((Int) -> Void)? = nil
    ) {
        _selectedID = selectedID
        self.items = items
        self.onSelectionChanged = onSelectionChanged
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: BiologerSpacing.small) {
                BiologerIconBadge(systemImage: headerIcon, size: 64)
                    .padding(.vertical, BiologerSpacing.small)

                ForEach(items) { item in
                    licenseCard(item)
                }
            }
            .padding(.horizontal, BiologerSpacing.regular)
            .padding(.bottom, BiologerSpacing.xxLarge)
        }
        .biologerPageBackground()
        .navigationBarBackButtonHidden(true)
    }

    private var headerIcon: String {
        items.first?.kind == .image ? "photo.fill" : "doc.text.fill"
    }

    private func licenseCard(_ item: LicenseOption) -> some View {
        BiologerSelectionCard(
            title: item.title,
            subtitle: item.details,
            isSelected: item.id == selectedID,
            subtitleFont: .caption,
            action: { select(item) }
        ) {
            BiologerIconBadge(
                systemImage: item.kind == .image ? "photo" : "doc.text"
            )
        }
        .allowsHitTesting(!isSelectionLocked)
    }

    private func select(_ item: LicenseOption) {
        guard !isSelectionLocked else { return }
        isSelectionLocked = true

        withAnimation(.easeInOut(duration: 0.18)) {
            selectedID = item.id
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSelectionChanged?(item.id)
        }
    }
}
