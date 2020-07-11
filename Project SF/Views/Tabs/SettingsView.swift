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
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
