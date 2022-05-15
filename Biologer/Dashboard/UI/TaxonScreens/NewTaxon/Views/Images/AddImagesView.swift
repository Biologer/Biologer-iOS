//
//  AddImagesView.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import SwiftUI

struct AddImagesView: View {
    
    let fotoButtonImage: String
    let galleryButtonImage: String
    
    let fotoButtonTapped: Observer<Void>
    let gallerButtonTapped: Observer<Void>
    
    var body: some View {
        Button(action: {
            fotoButtonTapped(())
        }, label: {
            Image(fotoButtonImage)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30, alignment: .center)
        })
        Button(action: {
            gallerButtonTapped(())
        }, label: {
            Image(galleryButtonImage)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30, alignment: .center)
        })
    }
}

struct AddImagesView_Previews: PreviewProvider {
    static var previews: some View {
        
        AddImagesView(fotoButtonImage: "foto_icon",
                      galleryButtonImage: "gallery_icon",
                      fotoButtonTapped: { _ in },
                      gallerButtonTapped: { _ in })
    }
}
