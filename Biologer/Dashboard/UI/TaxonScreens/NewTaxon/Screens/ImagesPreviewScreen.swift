//
//  ImagesPreviewScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 30.9.21..
//

import SwiftUI

struct ImagesPreviewScreen: View {
    
    @ObservedObject var viewModel: ImagesPreviewScreenViewModel
    
    var body: some View {
        ZStack {
            Color.black
            HStack(alignment: .center) {
                TabView(selection: $viewModel.selectionIndex) {
                    ForEach(0..<viewModel.images.count) { i in
                        Image(uiImage: viewModel.images[i].image)
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .animation(.easeInOut)
                .transition(.slide)
            }
        }
        .ignoresSafeArea(.container, edges: .all)
    }
}

struct ImagesPreviewScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let texonImages = [TaxonImage(image: UIImage(named: "intro1")!),
                           TaxonImage(image: UIImage(named: "taxon_background")!),
                           TaxonImage(image: UIImage(named: "intro3")!),
                           TaxonImage(image: UIImage(named: "taxon_background")!)]
        
        ImagesPreviewScreen(viewModel: ImagesPreviewScreenViewModel(images: texonImages, selectionIndex: 3))
    }
}
