//
//  ProfileSettings.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct ProfileSettings: View {

    @AppStorage("name") var name = ""
    @AppStorage("username") var username = ""
    @AppStorage("userDescription") var description = ""
    
    @StateObject var keyboard = KeyboardManager()
    
    @State var profilePicture: UIImage?
    @State var color = Color.clear

    @State var showSheet = false
    @State var selectedSheet = 0
    @State var showSelectAlert = false

    var body: some View {
        // This VStack and empty text is required to fix the navigation title glitching out on scroll
        // so ScrollView isn't the topmost view.
        NavScrollView {
            Button(action: {
//                profilePicture = UIImage(pixelImage: .randomSymmetrical(width: 6, height: 6))
                showSelectAlert = true
            }) {
                if profilePicture == nil {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                } else {
                    if color != .clear {
                        Image(uiImage: profilePicture!)
                            .interpolation(.none)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .foregroundColor(color)
                    } else {
                        Image(uiImage: profilePicture!)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    }
                }
            }

            TextField("Name", text: $name)
                .font(.headline)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .frame(minHeight: 50)
                        .foregroundColor(Color(.secondarySystemBackground))
                )
                .frame(minHeight: 50)
                .padding(.bottom, 8)
            
            TextField("Username", text: $username)
                .font(.headline)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .frame(minHeight: 50)
                        .foregroundColor(Color(.secondarySystemBackground))
                )
                .frame(minHeight: 50)
                .padding(.bottom, 8)

            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .frame(minHeight: 50)
                    .foregroundColor(Color(.secondarySystemBackground))
                    .onTapGesture {
                        UIApplication.shared.endEditing(true)
                    }
                VStack {
                    Text("Bio/Description")
                        .foregroundColor(Color(.tertiaryLabel))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextEditor(text: $description)
                        .cornerRadius(10)
                }
                .padding(16)
            }
            .frame(height: 250)
            
            Spacer(minLength: keyboard.currentHeight)
        }
        .padding(.horizontal)
        .navigationTitle("Profile")
        .actionSheet(isPresented: $showSelectAlert) {
            ActionSheet(title: Text("Select profile image"),
                        message: nil,
                        buttons: [
                            .default(Text("Open profile image creator"), action: {
                                selectedSheet = 0
                                showSheet = true
                            }), .default(Text("Select from image gallery"), action: {
                                selectedSheet = 1
                                showSheet = true
                            }), .cancel()])
        }
        .onChange(of: showSheet, perform: { showSheet in
            if !showSheet && selectedSheet == 1 {
                color = .clear
            }
        })
        .sheet(isPresented: $showSheet) {
            if selectedSheet == 0 {
                ProfileImageCreator($profilePicture, color: $color)
            } else {
                ImageSelectionView(image: $profilePicture)
            }
        }
    }
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileSettings()
        }
    }
}
