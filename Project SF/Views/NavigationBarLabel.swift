//
//  NavigationLabel.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct NavigationBarLabel<Destination: View>: View {

    let title: String?
    let systemName: String
    let destination: Destination

    var body: some View {
        NavigationLink(
            destination: destination,
            label: {
                if let title = title {
                    Label(title, systemImage: systemName)
                        .font(.title2)
                } else {
                    Image(systemName: systemName)
                        .font(.title2)
                }
            }
        )
    }

    init(title: String? = nil, systemName: String, destination: Destination) {
        self.title = title
        self.systemName = systemName
        self.destination = destination
    }
}

struct NavigationLabel<Destination: View>: View {

    let title: String?
    let systemName: String
    let destination: Destination

    var body: some View {
        NavigationLink(
            destination: destination,
            label: {
                if let title = title {
                    Label(title, systemImage: systemName)
                } else {
                    Image(systemName: systemName)
                }
            }
        )
    }

    init(title: String? = nil, systemName: String, destination: Destination) {
        self.title = title
        self.systemName = systemName
        self.destination = destination
    }
}

struct NavigationLabel_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Text("Hello, World!")
                .navigationTitle("Title")
                .navigationBarItems(trailing: NavigationBarLabel(systemName: "plus", destination: Text("123")))
        }
    }
}
