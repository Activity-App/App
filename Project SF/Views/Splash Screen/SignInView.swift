//
//  SignInView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct SignInView: View {

    @State var username = ""

    var body: some View {
        VStack {
            Spacer()
            GroupBox {
                TextField("Enter your name", text: $username) { (didChange) in
                    print(didChange)
                } onCommit: {
                    print("Commited")
                }
            }
            .padding()
            Spacer()
            RoundedButton("Continue") {
                print(123)
            }
        }
    }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
