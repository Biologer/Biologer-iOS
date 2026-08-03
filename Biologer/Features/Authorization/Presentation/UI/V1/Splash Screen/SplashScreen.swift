//
//  SplashScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 12.9.21..
//

import SwiftUI

struct SplashScreen: View {
    
    private var timer = Timer()
    private let onSplashScreenDone: Observer<Void>
    
    init(onSplashScreenDone: @escaping Observer<Void>) {
        self.onSplashScreenDone = onSplashScreenDone
    }
    
    var body: some View {
        VStack {
            Image("biologer_logo_icon")
                .resizable()
                .scaledToFit()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .biologerPageBackground()
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.all)
        .onAppear {
            Timer.scheduledTimer(
                withTimeInterval: 1.0,
                repeats: false)
            { _ in
                onSplashScreenDone(())
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen(onSplashScreenDone: { })
    }
}
