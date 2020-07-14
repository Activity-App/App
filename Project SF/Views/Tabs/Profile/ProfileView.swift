//
//  ProfileView.swift
//  Project SF
//
//  Created by Roman Esin on 13.07.2020.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            Text("Profile View")
                .navigationTitle("Profile")
                .navigationBarItems(trailing: NavigationBarLabel(systemName: "gearshape.fill",
                                                                 destination: SettingsView()))
        }
        .tabItem {
            Label("Profile", systemImage: "person.crop.circle")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
