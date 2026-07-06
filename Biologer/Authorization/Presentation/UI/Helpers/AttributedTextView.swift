//
//  AttributedTextView.swift
//  Biologer
//
//  Created by Nikola Popovic on 4.7.21..
//

import SwiftUI

struct AttributedTextView: UIViewRepresentable {

    typealias CustomLabel = UILabel
    var configuration = { (view: CustomLabel) in }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> CustomLabel { CustomLabel() }
    func updateUIView(_ uiView: CustomLabel, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)
    }
}
