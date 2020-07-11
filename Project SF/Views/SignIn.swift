//
//  SignIn.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI
import AuthenticationServices

struct SignIn: View {
    var body: some View {
        SignInWithAppleButton(.signIn,
                              onRequest: { request in

                              },
                              onCompletion: { result in

                              }
        )
    }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        SignIn()
    }
}
