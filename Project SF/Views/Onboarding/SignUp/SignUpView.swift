//
//  SignUpView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct SignUpView: View {

    @Binding var showOnboarding: Bool
    @AppStorage("username") var username = ""

    var body: some View {
        VStack {
            NavScrollView {
                Text("REQUIRED")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 32)
                GroupBox {
                    TextField("Name", text: $username) { didChange in
                        print(didChange)
                    } onCommit: {
                        print("Commited")
                    }
                }
                GroupBox {
                    TextField("Username", text: $username) { didChange in
                        print(didChange)
                    } onCommit: {
                        print("Commited")
                    }
                }
                
                Text("OPTIONAL")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 32)
                GroupBox {
                    TextField("Phone Number", text: $username) { didChange in
                        print(didChange)
                    } onCommit: {
                        print("Commited")
                    }
                }
                Text("This will be used so other people with your contact can discover you.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
            RoundedNavigationLink(
                "Continue", destination: GrantDataAccessView(showOnboarding: $showOnboarding)
            )
        }
        .padding(.horizontal)
        .navigationTitle("Sign Up")
    }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignUpView(showOnboarding: .constant(true))
        }
    }
}
