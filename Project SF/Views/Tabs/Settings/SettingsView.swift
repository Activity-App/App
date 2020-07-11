//
//  SettingsView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct AboutFooter: View {
    var body: some View {
        VStack(spacing: 8) {
            // I have no idea how to make this centered without this hack.
            // Branch rule test //
            HStack {
                Spacer()
                Text("Made with <3 by WWDC Scholars")
                    .padding(.top, 8)
                Spacer()
            }

            HStack {
                Spacer()
                Link("GitHub", destination: URL(string: "https://github.com/Activity-App/App")!)
                    .foregroundColor(.blue)
                Spacer()
            }
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("General"), content: {
                    NavigationLabel(title: "Profile",
                                  systemName: "person.crop.circle",
                                  destination: ProfileSettings())
                    NavigationLabel(title: "Notifications",
                                  systemName: "app.badge",
                                  destination: NotificationSettings())
                })

                Section(header: Text("Privacy"), footer: AboutFooter(), content: {
                    NavigationLabel(title: "Alter permissions",
                                  systemName: "heart.text.square",
                                  destination: PermissionSettings())
                    NavigationLabel(title: "Learn about privacy",
                                  systemName: "key",
                                  destination: PrivacyAbout())
                })
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Settings")
        }
        .tabItem {
            VStack {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18))
                Text("Settings")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
