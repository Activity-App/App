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
                    Text("This information will be viewable to the public when searching your username. You can leave this blank or change what you want to be shown to who later in settings.")
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
                    userController.user?.name = name
                    userController.user?.username = username
                    userController.user?.bio = bio
                    userController.save { error in
                        if error != nil {
                            print(error!)
                            presentErrorAlert()
                        } else {
                            DispatchQueue.main.async {
                                nextPage = true
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
            userController.setup { error in
                if let error = error {
                    print(error)
                    self.presentErrorAlert()
                }
            }
            UserDefaults.standard.setValue(true, forKey: "nameToPublicDb")
            UserDefaults.standard.setValue(true, forKey: "bioToPublicDb")
            UserDefaults.standard.setValue(true, forKey: "profilePictureToPublicDb")
            UserDefaults.standard.setValue(true, forKey: "nameSharedToFriends")
            UserDefaults.standard.setValue(true, forKey: "bioSharedToFriends")
            UserDefaults.standard.setValue(true, forKey: "profilePictureSharedToFriends")
        }
        .onDisappear {
            signedUp = false
        }
    }
    
    func presentErrorAlert() {
        DispatchQueue.main.async {
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
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignUpView(showOnboarding: .constant(true))
        }
    }
}
