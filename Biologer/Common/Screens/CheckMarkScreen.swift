import SwiftUI

protocol CheckMarkScreenLoader: ObservableObject {
    var items: [CheckMarkItem] { get }

    func itemTapped(item: CheckMarkItem)
}

struct CheckMarkScreen<Loader: CheckMarkScreenLoader>: View {
    @ObservedObject var loader: Loader

    var body: some View {
        ScrollView {
            VStack {
                ForEach(loader.items, id: \.id) { item in
                    HStack {
                        itemButton(item)
                        Spacer()
                        selectionButton(item)
                    }
                    Divider()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func itemButton(_ item: CheckMarkItem) -> some View {
        Button {
            loader.itemTapped(item: item)
        } label: {
            Text(item.title)
                .font(.titleFont)
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
        }
        .padding()
    }

    private func selectionButton(_ item: CheckMarkItem) -> some View {
        Button {
            loader.itemTapped(item: item)
        } label: {
            Image("check_mark")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 25)
                .isHidden(!item.isSelected)
        }
        .padding(10)
    }
}

public protocol CheckMarkScreenDelegate {
    func get(item: CheckMarkItem)
}

public final class CheckMarkScreenViewModel: CheckMarkScreenLoader {
    var items: [CheckMarkItem]

    private let onItemTapped: Observer<CheckMarkItem>
    private let delegate: CheckMarkScreenDelegate?

    init(
        items: [CheckMarkItem],
        selectedItem: CheckMarkItem,
        delegate: CheckMarkScreenDelegate? = nil,
        onItemTapped: @escaping Observer<CheckMarkItem>
    ) {
        self.items = items
        self.delegate = delegate
        self.onItemTapped = onItemTapped
        updateSelectedViewModel(with: selectedItem)
    }

    func itemTapped(item: CheckMarkItem) {
        delegate?.get(item: item)
        onItemTapped(item)
    }

    public func updateSelectedViewModel(with item: CheckMarkItem) {
        for (index, license) in items.enumerated() {
            items[index].changeIsSelected(value: license.id == item.id)
        }
    }
}
