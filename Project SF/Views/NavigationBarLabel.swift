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
                        .contentShape(Rectangle())
                } else {
                    Image(systemName: systemName)
                        .contentShape(Rectangle())
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

struct NavigationBarButton: View {

    let title: String?
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(
            action: action,
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

    init(title: String? = nil, systemName: String, action: @escaping () -> Void) {
        self.title = title
        self.systemName = systemName
        self.action = action
    }
}

struct NavigationButton: View {

    let title: String? = nil
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(
            action: action,
            label: {
                if let title = title {
                    Label(title, systemImage: systemName)
                        .contentShape(Rectangle())
                } else {
                    Image(systemName: systemName)
                        .contentShape(Rectangle())
                }
            }
        )
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
