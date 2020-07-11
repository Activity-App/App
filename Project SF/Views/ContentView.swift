//
//  ContentView.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

struct ContentView: View {

    @AppStorage("TabViewPage") var page = 3

    var body: some View {
        TabView(selection: $page) {
            CompetitionsView()
                .tag(1)

            TeamsView()
                .tag(2)

            SettingsView()
                .tag(3)
        }
        .accentColor(.init(red: 1, green: 0.4, blue: 0.4))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
