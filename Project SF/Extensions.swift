//
//  Extensions.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

extension View {
    public func foreground<Overlay: View>(_ overlay: Overlay) -> some View {
        self.overlay(overlay).mask(self)
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    let effectView = UIVisualEffectView(effect: nil)
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        effectView.effect = effect
        return effectView
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { }
}
