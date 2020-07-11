//
//  ProfileSettings.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct ProfileSettings: View {

    @AppStorage("username") var username = "My Name"
    @AppStorage("phone-number") var phoneNumber = "+7 (914) 690 52-28"
    @AppStorage("user-description") var description = ""

    @State var isShowingAlert = false

    var body: some View {
        ScrollView {
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
                    TextField("Enter your name", text: $username) { (didChange) in
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
                TextEditor(text: $description)
                    .cornerRadius(8)
            }
            .frame(height: 250)

        }
        .padding(.horizontal)
        .navigationTitle("Profile")
    }
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileSettings()
        }
    }
}
