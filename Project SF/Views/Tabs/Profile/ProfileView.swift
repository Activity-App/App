//
//  ProfileView.swift
//  Project SF
//
//  Created by Roman Esin on 13.07.2020.
//

import SwiftUI

struct ProfileView: View {

    @State var isSettingsPresented = false

    var body: some View {
        NavigationView {
            Text("Profile View")
                .navigationTitle("Profile")
                .navigationBarItems(trailing: Button(action: {
                    isSettingsPresented = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                })
        }
        .sheet(isPresented: $isSettingsPresented, onDismiss: {}) {
            NavigationView {
                SettingsView()
            }
        }
        .tabItem {
            Label("Profile", systemImage: "person.crop.circle")
                .font(.title2)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
