//
//  KeyboardManager.swift
//  Project SF
//
//  Created by Christian Privitelli on 12/7/20.
//

import SwiftUI

class KeyboardManager: ObservableObject {
    
    @Published var currentHeight: CGFloat = 0

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize =
            (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        currentHeight = 0
    }
}
