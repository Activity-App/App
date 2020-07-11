//
//  TeamsView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct TeamsView: View {
    var body: some View {
        NavigationView {
            Text("Teams")
                .navigationBarTitle("Teams")
        }
        .tabItem {
            VStack {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 18))
                Text("Teams")
            }
        }
        .tag(2)
    }
}

struct TeamsView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsView()
    }
}
