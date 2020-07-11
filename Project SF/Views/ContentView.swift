//
//  ContentView.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

struct ContentView: View {

    @State var page = 1

    var body: some View {
        TabView(selection: $page) {
            TodayView()
            
            CompetitionsView()

            SettingsView()
        }
        .accentColor(.init(red: 1, green: 0.4, blue: 0.4))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
