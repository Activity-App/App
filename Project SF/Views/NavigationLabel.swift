//
//  NavigationLabel.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct NavigationLabel<Destination: View>: View {
    let title: String
    let systemName: String
    let destination: Destination

    var body: some View {
        NavigationLink(
            destination: destination,
            label: {
                Label(title, systemImage: systemName)
            }
        )
    }
}
