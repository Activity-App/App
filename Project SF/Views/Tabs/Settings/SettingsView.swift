//
//  SettingsView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

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

                Section(header: Text("Privacy"), content: {
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
