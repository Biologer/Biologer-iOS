//
//  ListOfFindingsScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 14.6.21..
//

import SwiftUI
 
protocol ListOfFindingsScreenLoader: ObservableObject {
    func getData()
    var onNewItemTapped: Observer<Void> { get }
    var onItemTapped: Observer<Finding> { get }
    var onDeleteFindingTapped: Observer<Finding> { get }
    var preview: FindingsScreenPreviewType { get }
}

struct ListOfFindingsScreen: View {
    
    @ObservedObject public var viewModel: ListOfFindingsScreenViewModel
    
    var body: some View {
        ZStack {
            generateView(viewModel)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.onNewItemTapped(())
                    }, label: {
                        Image("add_token")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                    })
                    .padding()
                }
            }
        }
        .background(Color.biologerGreenColor.opacity(0.4))
        .ignoresSafeArea(.container, edges: .bottom)
        .onAppear {
            viewModel.getData()
        }
    }
    
    private func generateView(_ viewModel: ListOfFindingsScreenViewModel) -> AnyView {
        switch viewModel.preview {
        case .regular(let items):
            return AnyView(FindingsListView(items: items,
                                            onItemTapped: viewModel.onItemTapped,
                                            onDeleteFindingTapped: viewModel.onDeleteFindingTapped))
        case .iregular(let title):
            return AnyView(NoItemsView(title: title))
        }
    }
}

struct SideMenuMainScreen_Previews: PreviewProvider {
    static var previews: some View {
        ListOfFindingsScreen(viewModel: ListOfFindingsScreenViewModel(onNewItemTapped: { _ in },
                                                                      onItemTapped: { _ in}, onDeleteFindingTapped: { _ in }))
    }
    
    private class StubSideMenuMainScreenViewModel: ListOfFindingsScreenLoader {
        var onDeleteFindingTapped: Observer<Finding>
        
        func getData() {}
        
        var onNewItemTapped: Observer<Void>
        
        var onItemTapped: Observer<Finding>
        
        var preview: FindingsScreenPreviewType = .regular(FindingModelFactory.getFindgins())
        
        init(onNewItemTapped: @escaping Observer<Void>,
             onItemTapped: @escaping Observer<Finding>,
             onDeleteFindingTapped: @escaping Observer<Finding>) {
            self.onItemTapped = onItemTapped
            self.onNewItemTapped = onNewItemTapped
            self.onDeleteFindingTapped = onDeleteFindingTapped
        }
        
    }
}
