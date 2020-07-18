//
//  SettingsView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct AboutFooter: View {
    var body: some View {
        VStack {
            Text("Made with <3 by WWDC Scholars")
                .padding(.top, 8)
                .padding(.bottom, 4)
            Link("GitHub", destination: URL(string: "https://github.com/Activity-App/App")!)
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingsView: View {

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            Section(header: Text("General")) {
                NavigationLabel(
                    title: "Profile",
                    systemName: "person.crop.circle",
                    destination: ProfileSettings()
                )
                NavigationLabel(
                    title: "Notifications",
                    systemName: "app.badge",
                    destination: NotificationSettings()
                )
            }
            
            Section(header: Text("Privacy"), footer: AboutFooter()) {
                NavigationLabel(
                    title: "Alter permissions",
                    systemName: "heart.text.square",
                    destination: PermissionSettings()
                )
                NavigationLabel(
                    title: "Learn about privacy",
                    systemName: "key",
                    destination: PrivacyAbout()
                )
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
