//
//  HelpScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import Foundation

public final class HelpScreenViewModel: HelpScreenLoader, ObservableObject {
    var numerOfPages: Int = 4
    @Published var currentPageIndex: Int = 0
    
    private let onDone: Observer<Void>
    
    init(onDone: @escaping Observer<Void>) {
        self.onDone = onDone
    }
    
    func nextTapped() {
        if currentPageIndex < 3 {
            currentPageIndex += 1
        }
    }
    
    func previousTapped() {
        if currentPageIndex > 0 {
            currentPageIndex -= 1
        }
    }
}
