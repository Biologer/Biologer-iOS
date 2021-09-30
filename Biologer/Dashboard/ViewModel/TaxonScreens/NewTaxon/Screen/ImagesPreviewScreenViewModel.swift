//
//  ImagesPreviewScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import Foundation

public final class ImagesPreviewScreenViewModel: ObservableObject {
    public let images: [TaxonImage]
    @Published public var selectionIndex: Int
    
    init(images: [TaxonImage],
         selectionIndex: Int) {
        self.images = images
        self.selectionIndex = selectionIndex
    }
}
