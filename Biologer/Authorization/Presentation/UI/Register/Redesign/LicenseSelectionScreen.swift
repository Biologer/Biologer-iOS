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

    init(
        selectedItem: Binding<CheckMarkItem>,
        items: [CheckMarkItem]
    ) {
        _selectedItem = selectedItem
        _items = State(initialValue: items.selecting(selectedItem.wrappedValue))
    }

    var body: some View {
        ScrollView {
            VStack {
                ForEach(items) { item in
                    HStack {
                        Button(action: {
                            select(item)
                        }, label: {
                            Text(item.title)
                                .font(.titleFont)
                                .foregroundColor(Color.black)
                                .multilineTextAlignment(.leading)
                        })
                        .padding()
                        Spacer()
                        Button(action: {
                            select(item)
                        }, label: {
                            Image("check_mark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 25)
                                .isHidden(!item.isSelected)

                        })
                        .padding(10)
                    }
                    Divider()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: selectedItem) { item in
            updateSelectedViewModel(with: item)
        }
    }

    private func select(_ item: CheckMarkItem) {
        var selectedItem = item
        selectedItem.changeIsSelected(value: true)
        self.selectedItem = selectedItem
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
