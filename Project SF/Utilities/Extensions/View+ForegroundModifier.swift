//
//  View+ForegroundModifier.swift
//  Project SF
//
//  Created by William Taylor on 10/7/20.
//

import SwiftUI

extension View {
    
    public func foreground<Overlay: View>(_ overlay: Overlay) -> some View {
        self.overlay(overlay).mask(self)
    }
    
}
