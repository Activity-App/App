//
//  SettingsView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct SettingsLabel<Destination: View>: View {
    let title: String
    let systemName: String
    let destination: Destination

    var body: some View {
        NavigationLink(
            destination: destination,
            label: {
                Label(title, systemImage: systemName)
            })
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {

                Section(header: Text("General"), content: {
                    SettingsLabel(title: "Profile",
                                  systemName: "person.crop.circle",
                                  destination: Text("destination"))
                    SettingsLabel(title: "Notifications",
                                  systemName: "app.badge",
                                  destination: Text("destination"))
                })

                Section(header: Text("Privacy"), content: {
                    SettingsLabel(title: "Alter permissions",
                                  systemName: "heart.text.square",
                                  destination: Text("destination"))
                    SettingsLabel(title: "Learn about privacy",
                                  systemName: "key",
                                  destination: Text("destination"))
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
        .tag(3)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
