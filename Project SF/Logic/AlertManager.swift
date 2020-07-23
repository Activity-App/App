//
//  AlertManager.swift
//  Project SF
//
//  Created by Christian Privitelli on 23/7/20.
//

import SwiftUI

class AlertManager: ObservableObject {
    @Published var isPresented = false
    
    @Published var icon = "exclamationmark.triangle.fill"
    @Published var message = "An error occured."
    @Published var buttonTitle = "Try Again"
    @Published var buttonAction: () -> Void = {}
    @Published var color = Color.red
    
    func present(icon: String? = nil, message: String? = nil, color: Color? = nil, buttonTitle: String? = nil, buttonAction: (() -> Void)? = nil) {
        if let icon = icon {
            self.icon = icon
        }
        if let message = message {
            self.message = message
        }
        if let color = color {
            self.color = color
        }
        if let buttonTitle = buttonTitle {
            self.buttonTitle = buttonTitle
        }
        if let buttonAction = buttonAction {
            self.buttonAction = buttonAction
        }
        isPresented = true
    }
    
    func dismiss() {
        isPresented = false
    }
}
