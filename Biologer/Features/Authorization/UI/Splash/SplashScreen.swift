//
//  SplashScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 12.9.21..
//

import SwiftUI

struct SplashScreen: View {
    
    var viewModel: SplashScreenViewModel
    
    var body: some View {
        VStack {
            Image(viewModel.image)
                .resizable()
                .scaledToFit()
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.all)
        .onAppear {
            viewModel.goToLoginScreen()
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen(viewModel: SplashScreenViewModel(onSplashScreenDone: { _ in}))
    }
}
