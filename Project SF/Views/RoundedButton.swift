//
//  RoundedButton.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

/// A custom button with Text inside a rounded rect
/// which spans across the whole width of the screen.
struct RoundedButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.title2))
                .fontWeight(.medium)
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(16)
                .padding()
        }
    }

    /// Basic Init method.
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - action: The action that'll be performed on tap.
    init(_ title: String, action: @escaping () -> Void = {}) {
        self.title = title
        self.action = action
    }
}

struct RoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundedButton("Button title")
    }
}
