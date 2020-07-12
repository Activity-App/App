//
//  NavigationItem.swift
//  Project SF
//
//  Created by Roman Esin on 12.07.2020.
//

import SwiftUI

struct NavigationItem: View {
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(action: action, label: {
            Image(systemName: "plus")
        })
    }

    init(imageName: String, action: @escaping () -> Void = {}) {
        self.imageName = imageName
        self.action = action
    }
}

struct NavigationItem_Previews: PreviewProvider {
    static var previews: some View {
        NavigationItem()
    }
}
