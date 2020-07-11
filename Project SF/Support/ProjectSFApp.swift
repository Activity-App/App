//
//  ProjectSFApp.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

struct ProjectSFApp: App {
    
    let cloudKitStore = CloudKitStore.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
