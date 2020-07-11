//
//  RoundedButton.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

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

    init(_ title: String, action: (() -> Void)? = nil) {
        self.title = title
        self.action = action ?? {}
    }
}

struct RoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundedButton("Button title")
    }
}
