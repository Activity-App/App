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
    @State var bio = ""
    
    @State var nextPage = false
    @State var signedUp = false
    @State var makePublic = false
    
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
                        TextField("Username", text: $username)
                            .autocapitalization(.none)
                    }
                    
                    Text("OPTIONAL")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 32)
                    GroupBox {
                        TextField("Name", text: $name)
                            .autocapitalization(.words)
                    }
                    GroupBox {
                        VStack {
                            HStack {
                                Text("Bio")
                                    .foregroundColor(Color(.tertiaryLabel))
                                Spacer()
                            }
                            TextEditor(text: $bio)
                                .frame(height: 120)
                                .cornerRadius(8)
                        }
                    }
                    GroupBox {
                        Toggle("Public", isOn: $makePublic)
                    }
                    Text(
                        """
                        Your name, bio and profile picture are private and only visible to your friends by default.
                        You can choose to make this information public if you would like it to show to everyone.
                        """
                    )
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
                    userController.createPublicDataRecord { error in
                        if let error = error {
                            print(error)
                            presentErrorAlert()
                        } else {
                            let newUser = User(name: name, username: username, bio: bio)
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
            userController.updatePrivateUser { error in
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
