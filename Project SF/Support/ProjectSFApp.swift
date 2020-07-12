//
//  ProjectSFApp.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

struct ProjectSFApp: App {
    
    //let cloudKitStore = CloudKitStore.shared
    @AppStorage("showOnboarding") var showOnboarding = true
    @StateObject var healthKit = HealthKitController()
    
    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
                    .environmentObject(healthKit)
            } else {
                ContentView()
                    .environmentObject(healthKit)
                    .onAppear {
                        healthKit.authorizeHealthKit {
                            if healthKit.authorizationState == .granted {
                                healthKit.updateTodaysActivityData()
                            }
                        }
                    }
                    .transition(AnyTransition.opacity.animation(.linear(duration: 1)))
            }
        }
        
    }
}
