//
//  NewTaxonImageViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 28.9.21..
//

import SwiftUI

public final class TaxonImage {
    let id = UUID()
    let image: Image
    
    init(image: Image) {
        self.image = image
    }
}

public final class NewTaxonImageViewModel: ObservableObject {
    public let title: String = "NewTaxon.lb.image.title".localized
    public let fotoButtonImage: String = "foto_icon"
    public let galleryButtonImage: String = "gallery_icon"
    @Published public var choosenImages = [TaxonImage]()
    private let onFotoTapped: Observer<Void>
    private let onGalleryTapped: Observer<Void>
    private let onImageTapped: Observer<Image>
    
    init(choosenImages: [TaxonImage],
         onFotoTapped: @escaping Observer<Void>,
         onGalleryTapped: @escaping Observer<Void>,
         onImageTapped: @escaping Observer<Image>) {
        self.choosenImages = choosenImages
        self.onFotoTapped = onFotoTapped
        self.onGalleryTapped = onGalleryTapped
        self.onImageTapped = onImageTapped
    }
    
    public func fotoButtonTapped() {
        onFotoTapped(())
    }
    
    public func gallerButtonTapped() {
        onGalleryTapped(())
    }
    
    public func imageButtonTapped(selectedImage: Image) {
        onImageTapped((selectedImage))
    }
}
