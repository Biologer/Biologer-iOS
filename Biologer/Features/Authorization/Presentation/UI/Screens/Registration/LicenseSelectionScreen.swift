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

    private let onSelectionChanged: Observer<CheckMarkItem>?

    init(
        selectedItem: Binding<CheckMarkItem>,
        items: [CheckMarkItem],
        onSelectionChanged: Observer<CheckMarkItem>? = nil
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
        Button(action: { select(item) }) {
            HStack(alignment: .top, spacing: BiologerSpacing.small) {
                BiologerIconBadge(
                    systemImage: item.type == .image ? "photo" : "doc.text"
                )

                VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
                    Text(item.title)
                        .font(.body.weight(.semibold))
                        .foregroundColor(BiologerColors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(item.placeholder)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: BiologerSpacing.xSmall)

                Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(
                        item.isSelected
                            ? BiologerColors.accent
                            : Color(uiColor: .tertiaryLabel)
                    )
                    .padding(.top, BiologerSpacing.xxSmall)
            }
            .padding(BiologerSpacing.regular)
            .contentShape(Rectangle())
            .biologerCard(isSelected: item.isSelected)
        }
        .buttonStyle(.plain)
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

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
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

struct LicenseSelectionScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreviewContainer(
                selectedItem: PreviewData.dataLicenses[0],
                items: PreviewData.dataLicenses
            )
            .previewDisplayName("Data license")

            PreviewContainer(
                selectedItem: PreviewData.imageLicenses[1],
                items: PreviewData.imageLicenses
            )
            .previewDisplayName("Image license")
        }
    }

    private struct PreviewContainer: View {
        @State private var selectedItem: CheckMarkItem
        private let items: [CheckMarkItem]

        init(selectedItem: CheckMarkItem, items: [CheckMarkItem]) {
            _selectedItem = State(initialValue: selectedItem)
            self.items = items
        }

        var body: some View {
            NavigationView {
                LicenseSelectionScreen(
                    selectedItem: $selectedItem,
                    items: items
                )
                .navigationTitle(selectedItem.placeholder)
            }
        }
    }

    private enum PreviewData {
        static var dataLicenses: [CheckMarkItem] {
            [
                CheckMarkItem(
                    id: 10,
                    title: "Creative Commons Attribution-ShareAlike",
                    placeholder: "Data license",
                    type: .data,
                    isSelected: true
                ),
                CheckMarkItem(
                    id: 20,
                    title: "Creative Commons Attribution",
                    placeholder: "Data license",
                    type: .data,
                    isSelected: false
                ),
                CheckMarkItem(
                    id: 30,
                    title: "Creative Commons Zero",
                    placeholder: "Data license",
                    type: .data,
                    isSelected: false
                )
            ]
        }

        static var imageLicenses: [CheckMarkItem] {
            [
                CheckMarkItem(
                    id: 10,
                    title: "Creative Commons Attribution-ShareAlike",
                    placeholder: "Image license",
                    type: .image,
                    isSelected: false
                ),
                CheckMarkItem(
                    id: 20,
                    title: "Creative Commons Attribution",
                    placeholder: "Image license",
                    type: .image,
                    isSelected: true
                ),
                CheckMarkItem(
                    id: 30,
                    title: "All rights reserved",
                    placeholder: "Image license",
                    type: .image,
                    isSelected: false
                )
            ]
        }
    }
}
