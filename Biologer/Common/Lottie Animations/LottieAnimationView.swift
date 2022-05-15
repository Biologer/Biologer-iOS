//
//  LottieAnimationView.swift
//  Biologer
//
//  Created by Nikola Popovic on 12.12.21..
//

import Foundation

import SwiftUI
import Lottie

struct LottieAnimationView: UIViewRepresentable {
    
    var fileName: String
    
    func makeUIView(context: UIViewRepresentableContext<LottieAnimationView>) -> UIView {
        let view = UIView(frame: .zero)

        let animationView = AnimationView(frame: .zero)
        let animation = Animation.named(fileName)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
