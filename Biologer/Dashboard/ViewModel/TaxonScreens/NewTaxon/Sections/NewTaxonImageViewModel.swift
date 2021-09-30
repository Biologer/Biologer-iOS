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

protocol ImageCustomPickerDelegate {
    func updateImage(image: Image)
}

public final class NewTaxonImageViewModel: ObservableObject {
    public let title: String = "NewTaxon.lb.image.title".localized
    public let fotoButtonImage: String = "foto_icon"
    public let galleryButtonImage: String = "gallery_icon"
    public let noImagesAdded: String = "NewTaxon.image.placeholder.title".localized
    @Published public private(set) var choosenImages = [TaxonImage]()
    private let onFotoTapped: Observer<Void>
    private let onGalleryTapped: Observer<Void>
    private let onImageTapped: Observer<([TaxonImage], Int)>
    
    init(choosenImages: [TaxonImage],
         onFotoTapped: @escaping Observer<Void>,
         onGalleryTapped: @escaping Observer<Void>,
         onImageTapped: @escaping Observer<([TaxonImage], Int)>) {
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
    
    public func imageButtonTapped(selectedImageIndex: Int) {
        onImageTapped((choosenImages, selectedImageIndex))
    }
    
    public func isImagePlaceholder(image: Image) -> Bool {
        return image == Image("img_placeholder_icon")
    }
}

extension NewTaxonImageViewModel: ImageCustomPickerDelegate {
    func updateImage(image: Image) {
        if choosenImages.allSatisfy({ $0.image == Image("img_placeholder_icon")}) {
            choosenImages.removeAll()
        }
        choosenImages.append(TaxonImage(image: image))
        choosenImages.reverse()
    }
}


