//
//  HelpScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import Foundation

public struct HelpItemViewModel: Hashable, Identifiable {
    public let id = UUID()
    var title: String
    var description: String
    var image: String
}

public final class HelpScreenViewModel: HelpScreenLoader, ObservableObject {
    var items: [HelpItemViewModel] = HelpItemViewModelFactory.createHelpItems()
    var numerOfPages: Int = 5
    @Published var currentPageIndex: Int = 0
    
    private let onDone: Observer<Void>
    
    init(onDone: @escaping Observer<Void>) {
        self.onDone = onDone
    }
    
    func nextTapped() {
        if currentPageIndex < 3 {
            currentPageIndex += 1
        } else {
            onDone(())
        }
    }
    
    func previousTapped() {
        if currentPageIndex > 0 {
            currentPageIndex -= 1
        }
    }
}
