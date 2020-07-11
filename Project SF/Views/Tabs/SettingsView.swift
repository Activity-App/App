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
            Text("Settings")
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
