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
    @State var showImageSelectionView = false

    var body: some View {
        // This VStack and empty text is required to fix the navigation title glitching out on scroll
        // so ScrollView isn't the topmost view.
        NavScrollView {
            Button(action: {
//                showImageSelectionView = true
                profilePicture = UIImage(pixels: .random(width: 10, height: 10), width: 10, height: 10)
            }, label: {
                if profilePicture == nil {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                } else {
                    Image(uiImage: profilePicture!)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }
            })
            .padding(.bottom)

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
        .sheet(isPresented: $showImageSelectionView) {
            ImageSelectionView(image: $profilePicture)
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
