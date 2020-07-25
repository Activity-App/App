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
    @State var makePublic = true
    
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
                        Toggle("Searchable", isOn: $makePublic)
                    }
                    Text("This will be used so other people can search for you and add you as a friend. You will recieve a friend request that you can accept when someone tries to friends you.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                RoundedNavigationLinkButton(
                    "Continue",
                    destination: GrantDataAccessView(showOnboarding: $showOnboarding),
                    isLoading: $userController.loading,
                    isActive: $nextPage
                ) {
                    signedUp = true
                    userController.createUserInfoRecord { error in
                        if let error = error {
                            print(error)
                            presentErrorAlert()
                        } else {
                            let newUser = User(name: name, username: username)
                            userController.set(data: newUser, publicDb: makePublic) { error in
                                if let error = error {
                                    print(error)
                                    presentErrorAlert()
                                } else {
                                    print("success")
                                    nextPage = true
                                }
                            }
                        }
                    }
                    
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .padding(.horizontal)
            .navigationTitle("Sign Up")
        }
        .onAppear {
            userController.updateUser { error in
                if let error = error {
                    print(error)
                    presentErrorAlert()
                }
            }
        }
        .onDisappear {
            signedUp = false
        }
    }
    
    func presentErrorAlert() {
        alert.present(
            icon: "exclamationmark.icloud.fill",
            message: "There was an error accessing iCloud. Please check your internet connection and that your device is signed into iCloud.",
            color: .orange,
            buttonAction: {
                alert.dismiss()
            }
        )
    }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignUpView(showOnboarding: .constant(true))
        }
    }
}
