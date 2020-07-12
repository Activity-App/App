//
//  ProfileSettings.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI
import Combine

struct ProfileSettings: View {
    
    // MARK: Properties
    
    @AppStorage("phone-number") var phoneNumber = "+7 (914) 690 52-28"
    
    @State var nickname = ""
    
    @State var isShowingAlert = false
    @StateObject var controller = ProfileSettingsController()
    
    // MARK: View
    
    var body: some View {
        // This VStack and empty text is required to fix nav title glitching out on scroll
        // So ScrollView isnt the topmost view.
        // This VStack and empty text is required to fix the navigation title glitching out on scroll
        // so ScrollView isn't the topmost view.
        VStack(spacing: 0) {
            Text("")
            ScrollView {
                switch controller.userController.state {
                case .loading:
                    ProgressView()
                case .user(_):
                    if controller.userController.isSyncing {
                        ProgressView {
                            Text("Syncing")
                        }
                    }
                    Button(action: {
                        // TODO: Present image search through the gallery.
                    }, label: {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    })
                    .frame(height: 100)
                    .padding(.vertical)
                    
                    GroupBox {
                        HStack {
                            TextField("Enter your name", text: $controller.nicknameText) { (didChange) in
                                print(didChange)
                            } onCommit: {
                                controller.setNickname()
                            }
                            .multilineTextAlignment(.leading)
                            
                            Image(systemName: "pencil")
                        }
                        .font(.headline)
                    }
                    
                    GroupBox {
                        HStack {
                            TextField("Enter your phone number", text: $phoneNumber) { (didChange) in
                                print(didChange)
                            } onCommit: {
                                print("Commited")
                            }
                            .multilineTextAlignment(.leading)
                            
                            Image(systemName: "pencil")
                        }
                        .font(.headline)
                    }
                    
                    GroupBox {
                        HStack {
                            Text("Enter your bio or description")
                                .foregroundColor(Color(.tertiaryLabel))
                            Spacer()
                        }
                        TextEditor(text: $controller.bioText)
                            .cornerRadius(8)
                    }
                    .frame(height: 250)
                case .failure(let error):
                    Text("Error: \(error.localizedDescription)")
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle("Profile")
        .onAppear(perform: viewAppeared)
        .onDisappear(perform: viewDisappeared)
    }
    
    // MARK: Methods
    
    private func viewAppeared() {
        controller.setup()
    }
    
    private func viewDisappeared() {
        controller.setBio()
        controller.setNickname()
    }
    
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileSettings()
        }
    }
}
