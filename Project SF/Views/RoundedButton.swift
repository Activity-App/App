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
    @Environment(\.isEnabled) var isEnabled

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: 55)
                .background(isEnabled ? Color.accentColor : Color.accentColor.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(16)
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
        VStack {
            RoundedButton("Button title")
            RoundedButton("Button title").disabled(true)
        }
    }
}
