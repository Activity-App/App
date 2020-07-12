//
//  RoundedTextField.swift
//  Project SF
//
//  Created by Christian Privitelli on 12/7/20.
//

import SwiftUI

struct RoundedTextField: View {
    
    var title: String
    @Binding var text: String
    var onEditingChanged: (Bool) -> ()
    var onCommit: () -> ()
    
    init(
        _ title: String,
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> () = { _ in },
        onCommit: @escaping () -> () = { }
    ) {
        self.title = title
        self._text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
    
    var body: some View {
        TextField(title, text: $text, onEditingChanged: onEditingChanged, onCommit: onCommit)
            .font(.headline)
            .padding(.horizontal)
            .background(
                 RoundedRectangle(cornerRadius: 10, style: .continuous)
                     .frame(minHeight: 50)
                     .foregroundColor(Color(.secondarySystemBackground))
            )
            .frame(minHeight: 50)
            .padding(.vertical, 8)
    }
}

struct RoundedTextField_Previews: PreviewProvider {
    static var previews: some View {
        RoundedTextField("Test", text: .constant(""))
    }
}
