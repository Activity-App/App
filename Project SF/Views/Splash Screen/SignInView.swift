//
//  SignInView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct SignInView: View {

    @AppStorage("username") var username = ""

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

            Spacer()
            RoundedNavigationLink("Continue", destination: GrantDataAccessView())
        }
        .padding(.horizontal)
        .navigationTitle("Sign Up")
    }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignInView()
        }
    }
}
