//
//  ProfileSettings.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct ProfileSettings: View {

    @State var username = ""
    @State var description = ""

    @State var isShowingAlert = false

    var body: some View {
        ScrollView {
            Image(systemName: "person.crop.circle")
                .resizable()
                .frame(width: 100, height: 100)
                .padding(.bottom, 32)

            GroupBox {
                TextField("Enter your name", text: $username) { (didChange) in
                    print(didChange)
                } onCommit: {
                    print("Commited")
                }
            }

            GroupBox {
                Text("Enter your bio or description")
                    .foregroundColor(Color(.tertiaryLabel))
                TextEditor(text: $description)
                    .cornerRadius(8)
            }
            .frame(height: 400)

        }
        .padding(.horizontal)
        .navigationTitle("Profile")
    }

    init() {
        username = UserDefaults.standard.string(forKey: "username") ?? ""
    }
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileSettings()
        }
    }
}
