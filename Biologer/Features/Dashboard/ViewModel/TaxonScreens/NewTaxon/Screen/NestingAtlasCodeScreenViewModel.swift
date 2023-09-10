//
//  NestingAtlasCodeScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.10.21..
//

import Foundation

public final class NestingAtlasCodeItem: ObservableObject {
    let id: Int
    let name: String
    @Published var isSelected: Bool = false
    
    init(id: Int,
         name: String) {
        self.id = id
        self.name = name
    }
}

public protocol NestingAtlasCodeScreenViewModelDelegate {
    func updateNestingCode(code: NestingAtlasCodeItem)
}

public final class NestingAtlasCodeScreenViewModel: ObservableObject {
    @Published public private(set) var codes: [NestingAtlasCodeItem]
    private let previousSlectedCode: NestingAtlasCodeItem?
    private let delegate: NestingAtlasCodeScreenViewModelDelegate?
    private let onCodeTapped: Observer<Void>
    
    init(codes: [NestingAtlasCodeItem],
         previousSlectedCode: NestingAtlasCodeItem?,
         delegate: NestingAtlasCodeScreenViewModelDelegate?,
         onCodeTapped: @escaping Observer<Void>) {
        self.codes = codes
        self.previousSlectedCode = previousSlectedCode
        self.delegate = delegate
        self.onCodeTapped = onCodeTapped
        if let code = previousSlectedCode {
            selectAtlasCode(code: code)
        }
    }
    
    public func selectCode(_ code: NestingAtlasCodeItem) {
        selectAtlasCode(code: code)
        delegate?.updateNestingCode(code: code)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.onCodeTapped(())
        }
    }
    
    private func selectAtlasCode(code: NestingAtlasCodeItem) {
        codes.forEach({
            if $0.name == code.name {
                $0.isSelected = true
            } else {
                $0.isSelected = false
            }
        })
        self.objectWillChange.send()
    }
}
