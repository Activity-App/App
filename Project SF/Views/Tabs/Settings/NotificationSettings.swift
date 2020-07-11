//
//  NotificationSettings.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct NotificationSettings: View {
    var body: some View {
        List {
            Section {
                Toggle("High scores", isOn: .constant(true))
                Toggle("Challanges", isOn: .constant(true))
                Toggle("Competitions", isOn: .constant(true))
                Toggle("Messages", isOn: .constant(true))
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Notifications")
    }
}

struct NotificationSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NotificationSettings()
        }
    }
}
