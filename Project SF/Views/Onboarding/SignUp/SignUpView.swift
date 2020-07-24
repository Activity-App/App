//
//  SignUpView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct SignUpView: View {

    @Binding var showOnboarding: Bool
    
    @State var name = ""
    @State var username = ""
    
    @State var nextPage = false
    @State var signedUp = false
    @State var loading = false
    
    @StateObject var userController = UserController()
    @EnvironmentObject var alert: AlertManager

    var body: some View {
        ZStack {
            VStack {
                NavScrollView {
                    Text("REQUIRED")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 32)
                    GroupBox {
                        TextField("Name", text: $name)
                            .autocapitalization(.words)
                    }
                    GroupBox {
                        TextField("Username", text: $username)
                            .autocapitalization(.none)
                    }
                    
                    Text("OPTIONAL")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 32)
                    GroupBox {
                        TextField("Phone Number", text: $username)
                    }
                    Text("This will be used so other people with your contact can discover you.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                RoundedNavigationLinkButton(
                    "Continue",
                    destination: GrantDataAccessView(showOnboarding: $showOnboarding),
                    isLoading: $loading,
                    isActive: $nextPage
                ) {
                    signedUp = true
                    userController.set(name: name, username: username)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .padding(.horizontal)
            .navigationTitle("Sign Up")
        }
        .onChange(of: userController.state) { newState in
            switch newState {
            case .loading:
                loading = true
            case .user:
                loading = false
                if signedUp {
                    nextPage = true
                }
            case .failure(let error):
                loading = false
                print(error)
                alert.present(
                    icon: "exclamationmark.icloud.fill",
                    message: "There was an error accessing iCloud. Please check your internet connection and that your device is signed into iCloud.",
                    color: .orange,
                    buttonAction: {
                        alert.dismiss()
                        userController.updateData()
                    }
                )
            }
        }
        .onAppear {
            userController.updateData()
        }
        .onDisappear {
            signedUp = false
        }
    }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignUpView(showOnboarding: .constant(true))
        }
    }
}
