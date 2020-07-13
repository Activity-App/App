//
//  ContentView.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

struct ContentView: View {

    @AppStorage("tabViewPage") var page = 1

    var body: some View {
        TabView(selection: $page) {
            CompetitionsView()
                .tag(1)

            FriendsView()
                .tag(2)

            ProfileView()
                .tag(3)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
