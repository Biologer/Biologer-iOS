//
//  LicenseSelectionScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 7. 7. 2026..
//

import SwiftUI

struct LicenseSelectionScreen: View {

    @State
    private var items: [CheckMarkItem]

    @Binding
    private var selectedItem: CheckMarkItem

    @State
    private var isSelectionLocked = false

    private let onSelectionChanged: ((CheckMarkItem) -> Void)?

    init(
        selectedItem: Binding<CheckMarkItem>,
        items: [CheckMarkItem],
        onSelectionChanged: ((CheckMarkItem) -> Void)? = nil
    ) {
        _selectedItem = selectedItem
        _items = State(initialValue: items.selecting(selectedItem.wrappedValue))
        self.onSelectionChanged = onSelectionChanged
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: BiologerSpacing.small) {
                BiologerIconBadge(
                    systemImage: headerIcon,
                    size: 64
                )
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
        .onChange(of: selectedItem) { item in
            updateSelectedViewModel(with: item)
        }
    }

    private var headerIcon: String {
        items.first?.type == .image ? "photo.fill" : "doc.text.fill"
    }

    private func licenseCard(_ item: CheckMarkItem) -> some View {
        BiologerSelectionCard(
            title: item.title,
            subtitle: item.placeholder,
            isSelected: item.isSelected,
            subtitleFont: .caption,
            action: { select(item) }
        ) {
            BiologerIconBadge(
                systemImage: item.type == .image ? "photo" : "doc.text"
            )
        }
        .disabled(isSelectionLocked)
    }

    private func select(_ item: CheckMarkItem) {
        guard !isSelectionLocked else { return }
        isSelectionLocked = true

        var selectedItem = item
        selectedItem.changeIsSelected(value: true)

        withAnimation(.easeInOut(duration: 0.18)) {
            self.selectedItem = selectedItem
            updateSelectedViewModel(with: selectedItem)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSelectionChanged?(selectedItem)
        }
    }

    private func updateSelectedViewModel(with item: CheckMarkItem) {
        items = items.selecting(item)
    }
}

private extension Array where Element == CheckMarkItem {
    func selecting(_ selectedItem: CheckMarkItem) -> [CheckMarkItem] {
        map { item in
            var updatedItem = item
            updatedItem.changeIsSelected(value: item.id == selectedItem.id)
            return updatedItem
        }
    }
}
