//
//  SplashScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 12.9.21..
//

import Foundation

public final class SplashScreenViewModel {
    public let image: String = "biologer_logo_icon"
    public let onSplashScreenDone: Observer<Void>
    private var timer = Timer()
    
    init(onSplashScreenDone: @escaping Observer<Void>) {
        self.onSplashScreenDone = onSplashScreenDone
    }
    
    public func goToLoginScreen() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerTrigered), userInfo: nil, repeats: false)
    }
    
    @objc private func timerTrigered() {
        DispatchQueue.main.async { [weak self] in
            self?.onSplashScreenDone(())
        }
    }
}
